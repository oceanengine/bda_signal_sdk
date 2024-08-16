//
//  BDASignalManager.m
//  guiyinTest
//
//  Created by ByteDance on 2023/7/26.
//  Copyright 2023 Beijing Ocean Engine Network Technology Co., Ltd. 
//  SPDX-License-Identifier: MIT

#import "BDASignalManager.h"
#import "BDASignalUtility.h"
#import <UIKit/UISceneOptions.h>
#import <UIKit/UIOpenURLContext.h>
#import <WebKit/WKWebView.h>

@interface BDASignalManager ()

@property (nonatomic, copy) NSString *ipv4;
@property (nonatomic, copy) NSString *webViewUA;
@property (nonatomic, copy) NSString *openUrl;
@property (nonatomic, assign) BOOL canCollectIdfa;
@property (nonatomic, assign) BOOL enableDelayEvent;
@property (nonatomic, strong) NSMutableArray *cacheArray;

@end

@implementation BDASignalManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    static BDASignalManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BDASignalManager alloc] init];
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

+ (BOOL)getIdfaStatus {
    return [BDASignalManager sharedInstance].canCollectIdfa;
}

+ (void)trackEssentialEventWithName:(NSString *)key params:(NSDictionary *)params {
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

#pragma mark lazy
- (NSMutableDictionary *)extraParam {
    if (!_extraParam) {
        _extraParam = [NSMutableDictionary dictionary];
    }
    return _extraParam;
}

@end
