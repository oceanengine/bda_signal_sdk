//
//  BDASignalManager.m
//
//  Created by ByteDance on 2023/7/26.
//  Copyright 2023 Beijing Ocean Engine Network Technology Co., Ltd.
//  SPDX-License-Identifier: MIT

#import "BDASignalManager.h"
#import "BDASignalUtility.h"
#import <CommonCrypto/CommonDigest.h>
#import <StoreKit/StoreKit.h>
#import <UIKit/UISceneOptions.h>
#import <UIKit/UIOpenURLContext.h>
#import <WebKit/WKWebView.h>
#import "BDASignalIDRequestLib-Swift.h"

@interface BDASignalManager () <SKPaymentTransactionObserver>

@property (nonatomic, copy) NSString *ipv4;
@property (nonatomic, copy) NSString *webViewUA;
@property (nonatomic, copy) NSString *openUrl;
@property (nonatomic, assign) BOOL canCollectIdfa;
@property (nonatomic, assign) BOOL canCollectPurchase;
@property (nonatomic, assign) BOOL enableDelayEvent;
@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, strong) BDASignalEventUploadCallback uploadBlock;

@property (nonatomic, copy) NSDictionary *config;
@property (nonatomic, strong) NSTimer *heartTimer;
@property (nonatomic, assign) BOOL isColdStart;
@property (nonatomic, assign) NSInteger sessionIndex;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSDictionary *mobileInfo;
@property (nonatomic, strong) NSMutableDictionary *requestManagerDict;

@end

@implementation BDASignalManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isColdStart = YES;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.config = [userDefaults objectForKey:@"kBDASignalConfig"] ?: @{
            @"play_session_interval": @(600000),
            @"uaid": @{
                    @"mobile": @{
                        @"enable": @1, // token刷新间隔, ms
                        @"renew_interval": @3300000 // token刷新间隔, ms
                    },
                    @"unicom": @{
                        @"enable": @1,  // token刷新间隔, ms
                        @"renew_interval": @40000 // token刷新间隔, ms
                    },
                    @"telecom": @{
                        @"enable": @1, // token刷新间隔, ms
                        @"renew_interval": @3300000 // token刷新间隔, ms
                    }
                },
        };
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAppDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAppWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [self collectUDIfNeeded];
        [BDASignalUtility updateConfig];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static BDASignalManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BDASignalManager alloc] init];
        manager.canCollectIdfa = YES;
        [BDASignalUtility getInternetIpv4WithResult:^(NSString *ipv4) {
            manager.ipv4 = ipv4;
        }];
        [manager preGetCachedData];
    });
    return manager;
}

+ (void)registerWithOptionalData:(NSDictionary *)config {
    [[BDASignalManager sharedInstance].extraParam addEntriesFromDictionary:config];
}

+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions connectOptions:(UISceneConnectionOptions *)connetOptions{
    if (![BDASignalManager sharedInstance]) {
        return;
    }
    
    [[BDASignalManager sharedInstance] startHeartEventIfNeeded];
    [[BDASignalManager sharedInstance] uploadSessionEventIfNeeded];
    [[BDASignalManager sharedInstance] storeSessionStartParam];
    
    // 解析clickid
    [self anylyseDeeplinkClickidWithOptions:launchOptions connectOptions:connetOptions];
    
    if ([BDASignalManager sharedInstance].enableDelayEvent) {
        [[BDASignalManager sharedInstance].cacheArray addObject:@{
            @"event_name" : @"launch_app",
        }];
        return;
    }
    [BDASignalUtility requestSignalWithParams:@{
        @"event_name" : @"launch_app",
    }];
}

+ (NSString *)anylyseDeeplinkClickidWithOpenUrl:(NSString *)openUrl {
    NSDictionary *queryDict = [BDASignalUtility getQueryDictWithUrl:openUrl];
    NSString *clickid = [queryDict objectForKey:@"clickid"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (openUrl.length > 0) {
        [userDefaults setObject:openUrl forKey:@"kBDASignalOpenUrl"];
    }
    if ([clickid isKindOfClass:[NSString class]] && clickid.length > 0) {
        [BDASignalManager sharedInstance].clickid = clickid;
        [userDefaults setObject:clickid forKey:@"kBDASignalClickid"];
    }
    [userDefaults synchronize];
    return clickid;
}

+ (NSString *)getClickId {
    return [BDASignalManager sharedInstance].clickid;
}

+(NSString *)getCacheOpenUrl {
    return [BDASignalManager sharedInstance].openUrl;
}

+ (NSDictionary *)getExtraParams {
    return [BDASignalManager sharedInstance].extraParam;
}

+ (NSString *)getIpv4 {
    return [BDASignalManager sharedInstance].ipv4;
}

+ (NSString *)getWebviewUA {
    return [BDASignalManager sharedInstance].webViewUA;
}

+ (void)enableIdfa:(BOOL)enable {
    [BDASignalManager sharedInstance].canCollectIdfa = enable;
}

+ (void)enablePurchaseEvent {
    [BDASignalManager sharedInstance].canCollectPurchase = YES;
    [[BDASignalManager sharedInstance] collectPurchaseEventIfNeeded];
}

+ (BOOL)getIdfaStatus {
    return [BDASignalManager sharedInstance].canCollectIdfa;
}

+ (void)trackEssentialEventWithName:(NSString *)key params:(NSDictionary *)params {
    if (![BDASignalManager sharedInstance]) {
        return;
    }
    if (key.length > 0) {
        if ([BDASignalManager sharedInstance].enableDelayEvent) {
            [[BDASignalManager sharedInstance].cacheArray addObject:@{
                @"event_name" : key,
                @"params" : params ?: @{}
            }];
            return;
        }
        [BDASignalUtility requestSignalWithParams:@{
            @"event_name" : key,
            @"params" : params ?: @{}
        }];
    }
}

+ (void)registerEventUploadCallback:(BDASignalEventUploadCallback)callback {
    [BDASignalManager sharedInstance].uploadBlock = callback;
}

+ (void)handleEventUploadResult:(NSDictionary *)result {
    if ([BDASignalManager sharedInstance].uploadBlock && result) {
        [BDASignalManager sharedInstance].uploadBlock(result);
    }
}

+ (NSString *)getCurrentSessionId {
    if ([BDASignalManager sharedInstance].sessionId) {
        return [BDASignalManager sharedInstance].sessionId;
    }
    const char *original_str = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString *sessionId = [NSString stringWithFormat:@"%@%@", @(ceil([[NSDate date] timeIntervalSince1970]*1000)).stringValue, hash ?: @""];
    [BDASignalManager sharedInstance].sessionId = sessionId;
    return sessionId;
}

+ (NSInteger)getCurrentSessionIndex {
    return [BDASignalManager sharedInstance].sessionIndex;
}

+ (NSDictionary *)getCurrentMobileInfo {
    return [BDASignalManager sharedInstance].mobileInfo;
}

#pragma mark 标准方法
+ (void)trackPayEventWithType:(kBDASignalPayStandardEventType)type revenue:(NSNumber *)revenue currency:(NSString *)currency adn:(NSString *)adn {
    NSString *event = nil;
    if (type == kBDASignalPayStandardEventTypePay) {
        event = @"lt_roi";
    } else if (type == kBDASignalPayStandardEventTypeClick) {
        event = @"click_lt_roi";
    } else if (type == kBDASignalPayStandardEventTypeEffectPlay3) {
        event = @"lt_roi_3s";
    }
    if (!event) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"revenue"] = revenue;
    params[@"currency"] = currency;
    params[@"adn"] = adn;
    [BDASignalUtility requestSignalWithParams:@{
        @"event_name" : event,
        @"params" : params ?: @{},
    }];
}

#pragma mark private
+ (void)anylyseDeeplinkClickidWithOptions:(NSDictionary *)launchOptions connectOptions:(UISceneConnectionOptions *)connetOptions {
    // 解析clickid
    NSString *openUrl = nil;
    if (launchOptions) {
        NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
        openUrl = url.absoluteString;
    } else if (connetOptions) {
        NSSet<UIOpenURLContext *> *urlSet = connetOptions.URLContexts;
        UIOpenURLContext *context = [urlSet allObjects].firstObject;
        openUrl = context.URL.absoluteString;
    }
    [self anylyseDeeplinkClickidWithOpenUrl:openUrl];
}

- (void)preGetCachedData {
    // 先获取缓存的UA
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *webviewUA = [userDefaults objectForKey:@"kBDASignalWebviewUA"];
    self.webViewUA = webviewUA;
    static WKWebView *webView;
    webView = [[WKWebView alloc] init];
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError * _Nullable error) {
        if ([result isKindOfClass:[NSString class]] && [result length]) {
            [userDefaults setObject:result forKey:@"kBDASignalWebviewUA"];
            [userDefaults synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.webViewUA = result;
            });
        }
        webView = nil;
    }];
    
    // 获取缓存的clickid
    NSString *clickid = [userDefaults objectForKey:@"kBDASignalClickid"];
    self.clickid = clickid;
    
    self.openUrl = [userDefaults objectForKey:@"kBDASignalOpenUrl"];
}

+ (void)enableDelayUpload {
    [BDASignalManager sharedInstance].enableDelayEvent = YES;
    [BDASignalManager sharedInstance].cacheArray = [NSMutableArray array];
}

+ (void)startSendingEvents {
    [BDASignalManager sharedInstance].enableDelayEvent = NO;
    // 触发未上报的缓存事件
    [[BDASignalManager sharedInstance].cacheArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [BDASignalUtility requestSignalWithParams:obj];
    }];
    [[BDASignalManager sharedInstance].cacheArray removeAllObjects];
    [BDASignalManager sharedInstance].cacheArray = nil;
}

#pragma mark purchase
- (void)collectPurchaseEventIfNeeded {
    if (self.canCollectPurchase) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                [self uploadPurchaseEventWith:obj];
            }
                break;
                
            default:
                break;
        }
    }];
}

- (void)uploadPurchaseEventWith:(SKPaymentTransaction *)transaction {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    SKPayment *payment = transaction.payment;
    params[@"statue"] = @(1);
    params[@"product_id"] = payment.productIdentifier;
    
    
}

#pragma mark mobile info
- (NSInteger)judgeIsMobileInfoValid:(NSDictionary *)detailConfig lastInfo:(NSDictionary *)lastInfo {
    // 0 config关闭 1 有效 2 过期失效 3 无值开启
    id enableValue = [detailConfig valueForKey:@"enable"];
    if ([enableValue isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)enableValue;
        if (num.integerValue == 0) {
            return 0;
        }
    }
    if (!lastInfo) {
        return 3;
    }
    
    id intervalValue = [detailConfig valueForKey:@"renew_interval"];
    NSNumber *lastTime = [lastInfo objectForKey:@"timestamp"];
    if ([intervalValue isKindOfClass:[NSNumber class]]) {
        NSNumber *interval = (NSNumber *)intervalValue;
        if ([[NSDate date] timeIntervalSince1970] - lastTime.doubleValue > interval.doubleValue/1000) {
            // 过期
            return 2;
        } else {
            return 1;
        }
    }
    
    return 0;
}

- (void)collectUDIfNeeded {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *lastMobileInfo = [userDefaults objectForKey:@"kBDASignalMobileInfo"];
    NSString *lastType = [lastMobileInfo objectForKey:@"type"];
    NSDictionary *udConfig = [self.config objectForKey:@"uaid"];
    if (!udConfig) {
        return;
    }
    if (lastType) {
        NSDictionary *detailConfig = [udConfig objectForKey:lastType];
        NSInteger status = [self judgeIsMobileInfoValid:detailConfig lastInfo:lastMobileInfo];
        if (status == 1) {
            self.mobileInfo = lastMobileInfo;
        } else if (status == 2) {
            self.mobileInfo = nil;
            [self sendCollectRequestWithType:lastType needUpdate:YES];
        } else {
            self.mobileInfo = nil;
        }
    } else {
        NSDictionary *mobileConfig = [udConfig objectForKey:@"mobile"];
        NSDictionary *unicomConfig = [udConfig objectForKey:@"unicom"];
        NSDictionary *telecomConfig = [udConfig objectForKey:@"telecom"];
        if ([self judgeIsMobileInfoValid:mobileConfig lastInfo:nil] == 3) {
            [self sendCollectRequestWithType:@"mobile" needUpdate:NO];
        }
        if ([self judgeIsMobileInfoValid:unicomConfig lastInfo:nil] == 3) {
            [self sendCollectRequestWithType:@"unicom" needUpdate:NO];
        }
        if ([self judgeIsMobileInfoValid:telecomConfig lastInfo:nil] == 3) {
            [self sendCollectRequestWithType:@"telecom" needUpdate:NO];
        }
    }
}

- (void)sendCollectRequestWithType:(NSString *)type needUpdate:(BOOL)update {
    __weak typeof(self) weakSelf = self;
    BDASignalSwiftRequestManager *swiftManager = [[BDASignalSwiftRequestManager alloc] init];
    if (!swiftManager) {
        return;
    }
    [self.requestManagerDict setObject:swiftManager forKey:type];
    [swiftManager requestTelIfNeededWithIpv4:self.ipv4 type:type with:^(NSDictionary * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (![result objectForKey:@"token"] || ![result objectForKey:@"type"] || [[result objectForKey:@"token"] isEqualToString:@"null"]) {
                if (update) {
                    [userDefaults removeObjectForKey:@"kBDASignalMobileInfo"];
                    [userDefaults synchronize];
                }
            } else {
                __strong typeof(self) strongSelf = weakSelf;
                NSMutableDictionary *mutDict = @{
                    @"timestamp" : @([[NSDate date] timeIntervalSince1970])
                }.mutableCopy;
                [mutDict addEntriesFromDictionary:result];
                strongSelf.mobileInfo = mutDict;
                [userDefaults setObject:mutDict forKey:@"kBDASignalMobileInfo"];
                [userDefaults synchronize];
                [BDASignalUtility requestSignalWithParams:@{
                    @"event_name" : @"launch_addition",
                }];
            }
            [self.requestManagerDict removeObjectForKey:type];
        });
    }];
}

#pragma mark session event
- (void)uploadSessionEventIfNeeded {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults objectForKey:@"kBDASignalSessionStatistics"];
    if (dict) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:dict];
        NSNumber *launchTime = [dict objectForKey:@"launch_time"];
        NSNumber *terminateTime = [dict objectForKey:@"terminate_time"];
        if (launchTime.doubleValue <= 0 || terminateTime.doubleValue <= 0 || terminateTime.doubleValue < launchTime.doubleValue) {
            [userDefaults removeObjectForKey:@"kBDASignalSessionStatistics"];
            [userDefaults synchronize];
            return;
        }
        params[@"duration"] = @(terminateTime.doubleValue - launchTime.doubleValue);
        params[@"session_id"] = self.sessionId;
        [BDASignalUtility requestSignalWithParams:@{
            @"event_name" : @"session_sync",
            @"params" : params ?: @{}
        }];
    }
    [userDefaults removeObjectForKey:@"kBDASignalSessionStatistics"];
    [userDefaults synchronize];
}

- (void)storeSessionStartParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sessionDict = [NSMutableDictionary dictionary];
    sessionDict[@"is_hot_launch"] = self.isColdStart ? @0 : @1;
    sessionDict[@"session_start"] = @([[NSDate date] timeIntervalSince1970]);
    sessionDict[@"session_num"] = @(self.sessionIndex);
    sessionDict[@"launch_time"] = @([[NSDate date] timeIntervalSince1970]);
    [userDefaults setObject:sessionDict forKey:@"kBDASignalSessionStatistics"];
    [userDefaults synchronize];
}
    
- (void)storeSessionLeaveParam:(BOOL)isTerminate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults objectForKey:@"kBDASignalSessionStatistics"];
    if (dict) {
        NSMutableDictionary *sessionDict = [NSMutableDictionary dictionary];
        [sessionDict addEntriesFromDictionary:dict];
        sessionDict[@"terminate_time"] = @([[NSDate date] timeIntervalSince1970]);
        sessionDict[@"switch_type"] = isTerminate ? @(2) : @(1);
        [userDefaults setObject:sessionDict forKey:@"kBDASignalSessionStatistics"];
    }
    [userDefaults synchronize];
}

- (void)startHeartEventIfNeeded {
    id value = [self.config objectForKey:@"play_session_interval"];
    NSInteger interval = 0;
    if ([value isKindOfClass:[NSNumber class]]) {
        interval = ((NSNumber *)value).integerValue;
    }
    if (interval <= 0) {
        return;
    }
    
    [self stopHeartEventIfNeeded];
    self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:interval/1000 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [BDASignalUtility requestSignalWithParams:@{
            @"event_name" : @"play_session",
        }];
    }];
}

- (void)stopHeartEventIfNeeded {
    if (self.heartTimer) {
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
}

#pragma mark lifecircle
- (void)onApplicationWillEnterForeground:(NSNotification *)not {
    if (!self.isColdStart) {
        [self uploadSessionEventIfNeeded];
        self.sessionIndex += 1;
        [self storeSessionStartParam];
        [self startHeartEventIfNeeded];
    }
}

- (void)onAppDidEnterBackground:(NSNotification *)notification {
    self.isColdStart = NO;
    [self storeSessionLeaveParam:NO];
    [self stopHeartEventIfNeeded];
}

- (void)onAppWillTerminate:(NSNotification *)notification {
    [self storeSessionLeaveParam:YES];
}

#pragma mark lazy
- (NSMutableDictionary *)extraParam {
    if (!_extraParam) {
        _extraParam = [NSMutableDictionary dictionary];
    }
    return _extraParam;
}

- (NSMutableDictionary *)requestManagerDict {
    if (!_requestManagerDict) {
        _requestManagerDict = [NSMutableDictionary dictionary];
    }
    return _requestManagerDict;
}

@end
