//
//  BDASignalUtility.m
//  guiyinTest
//
//  Created by ByteDance on 2023/7/26.
//
//  Copyright 2023 Beijing Ocean Engine Network Technology Co., Ltd. 
//  SPDX-License-Identifier: MIT

#import "BDASignalUtility.h"
#import "BDASignalManager.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <netdb.h>
#import <sys/mount.h>
#import <sys/stat.h>
#import <sys/sysctl.h>
#import <UIKit/UIDevice.h>

@implementation BDASignalUtility

+ (void)requestSignalWithParams:(NSDictionary *)params {
    // 拼接请求参数
    NSDictionary *extraParam = [params objectForKey:@"params"];
    NSString *eventName = [params objectForKey:@"event_name"];
    
    NSMutableDictionary *bodyParams = [NSMutableDictionary dictionary];
    bodyParams[@"event_name"] = [params objectForKey:@"event_name"];
    bodyParams[@"params"] = [BDASignalUtility bda_jsonStringEncodedWithDict:extraParam];;
    bodyParams[@"local_time"] = @([[NSDate date] timeIntervalSince1970]).stringValue;;
    
    NSMutableDictionary *userParam = [NSMutableDictionary dictionary];
    NSDictionary *userExtraParam = [BDASignalManager getExtraParams];
    userParam[@"user_unique_id"] = [userExtraParam objectForKey:kBDADSignalSDKUserUniqueId];
    bodyParams[@"user"] = userParam;
    
    NSMutableDictionary *headerParam = [NSMutableDictionary dictionary];
    headerParam[@"idfv"] = [self idfv];
    headerParam[@"idfa"] = [BDASignalManager getIdfaStatus] ? [self idfa] : @"";
    headerParam[@"sys_file_time"] = [self systemFileTime];
    headerParam[@"device_name"] = [self deviceName];;
    headerParam[@"device_model"] = [self deviceModel];
    headerParam[@"model"] = [self hardwareModel];;
    headerParam[@"boot_time_sec"] = [self systemBootTime];
    headerParam[@"system_version"] = [self systemVersion];
    headerParam[@"memory"] = [self systemMemorySize];
    headerParam[@"disk"] = [self systemDiskSize];
    headerParam[@"device_mnt_id"] = [self mntID];
    headerParam[@"device_init_time"] = [self deviceInitTime];
    headerParam[@"user_agent"] = [self webviewUA];
    headerParam[@"sdk_version"] = kBDADSignalSDKVersion;
    headerParam[@"click_id"] = [BDASignalManager getClickId];
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    headerParam[@"app_version"] = [appInfo objectForKey:@"CFBundleShortVersionString"];
    headerParam[@"app_package"] = [appInfo objectForKey:@"CFBundleIdentifier"];
    headerParam[@"deeplink"] = [BDASignalManager getCacheOpenUrl];
    // ip
    NSDictionary *ips = [self getIPAddresses];
    NSMutableString *utun = [NSMutableString string];
    BOOL analysedFlag = NO;
    NSInteger index = 0;
    NSArray *ipKeys = ips.allKeys;
    while (!analysedFlag) {
        NSString *key = [NSString stringWithFormat:@"utun%@/ipv6", @(index)];
        if ([ipKeys containsObject:key]) {
            [utun appendString:[NSString stringWithFormat:@"%@,", [ips objectForKey:key]]];
        } else {
            analysedFlag = YES;
        }
        index++;
    }
    if (utun.length > 0) {
        [utun deleteCharactersInRange:NSMakeRange(utun.length - 1, 1)];
    }
    headerParam[@"client_tun"] = utun;
    headerParam[@"client_anpi"] = [ips objectForKey:@"anpi0/ipv6"];
    headerParam[@"ipv4"] = [BDASignalManager getIpv4];
    headerParam[@"ipv6"] = [ips objectForKey:@"en0/ipv6"] ?: [ips objectForKey:@"pdp_ip0/ipv6"];
    bodyParams[@"header"] = headerParam;
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyParams options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:@"https://analytics.oceanengine.com/sdk/app"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if ([eventName isEqualToString:@"launch_app"]) {
                // 冷启请求失败需要重试
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf requestSignalWithParams:params];
                });
            }
            NSLog(@"采集SDK上报结果失败 error:%@", error.userInfo ?: @"nil");
        } else if (data) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"采集SDK上报结果，response：%@ message:%@ error:%@", result ?: @"", [result objectForKey:@"message"] ?: @"", error.userInfo ?: @"nil");
        }
    }];
    [task resume];
}

+ (NSString *)idfv {
    static NSString *cachedIdfv = nil;
    if (cachedIdfv) {
        return cachedIdfv;
    }
    cachedIdfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return cachedIdfv;
}

+ (NSString *)idfa {
    static NSString *cachedIdfa = nil;
    if (cachedIdfa) {
        return cachedIdfa;
    }
    cachedIdfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return cachedIdfa;
}

+ (NSString *)systemFileTime {
    static NSString *cachedSystemFileTime = nil;
    if (cachedSystemFileTime) {
        return cachedSystemFileTime;
    }
    NSString *result = nil;
    NSString *information = @"L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0";
    NSData *data=[[NSData alloc] initWithBase64EncodedString:information options:0];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dataString error:&error];
    if (fileAttributes) {
        id singleAttibute = [fileAttributes objectForKey:NSFileCreationDate];
        if ([singleAttibute isKindOfClass:[NSDate class]]) {
            NSDate *dataDate = singleAttibute;
            result = [NSString stringWithFormat:@"%f", [dataDate timeIntervalSince1970]];
        }
    }
    cachedSystemFileTime = result;
    return cachedSystemFileTime;
}

+ (NSString *)deviceName {
    static NSString *cachedDeviceName = nil;
    if (cachedDeviceName) {
        return cachedDeviceName;
    }
    const char *original_str = [UIDevice currentDevice].systemVersion.integerValue >= 16.0 ? [@"iPhone" UTF8String] : [[UIDevice currentDevice].name UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    cachedDeviceName = [hash lowercaseString];
    return cachedDeviceName;
}

+ (NSString *)deviceModel {
    static NSString *cachedDeivceModel = nil;
    if (cachedDeivceModel) {
        return cachedDeivceModel;
    }
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *machineModel = [NSString stringWithUTF8String:machine];
    free(machine);
    cachedDeivceModel = machineModel;
    return cachedDeivceModel;
}

+ (NSString *)hardwareModel {
    static NSString *cachedHardwareModel = nil;
    if (cachedHardwareModel) {
        return cachedHardwareModel;
    }
    size_t size;
    sysctlbyname("hw.model", NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname("hw.model", answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    cachedHardwareModel = results;
    return cachedHardwareModel;
}

+ (NSString *)systemBootTime {
    static NSString *cachedSystemBootTime = nil;
    if (cachedSystemBootTime) {
        return cachedSystemBootTime;
    }
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    sysctl(mib, 2, &boottime, &size, NULL, 0);
    NSTimeInterval bootSec = (NSTimeInterval)boottime.tv_sec + boottime.tv_usec / 1000000.0f;
    cachedSystemBootTime = @(bootSec).stringValue;
    return cachedSystemBootTime;
}

+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];;
}

+ (NSString *)systemMemorySize {
    static NSString *cachedSystemMemorySize = nil;
    if (cachedSystemMemorySize) {
        return cachedSystemMemorySize;
    }
    long long totalMemorySize = [NSProcessInfo processInfo].physicalMemory;
    cachedSystemMemorySize = @(totalMemorySize).stringValue;
    return cachedSystemMemorySize;
}

+ (NSString *)systemDiskSize {
    static NSString *cachedSystemDiskSize = nil;
    if (cachedSystemDiskSize) {
        return cachedSystemDiskSize;
    }
    int64_t space = -1;
    struct statfs buf;
    int result = syscall(345,"/", &buf);
    space = buf.f_bsize * buf.f_bfree;
    if (space < 0) {
        space = -1;
    }
    cachedSystemDiskSize = [NSString stringWithFormat:@"%lld", space];
    return cachedSystemDiskSize;
}

+ (NSString *)mntID {
    static NSString *cachedMntID = nil;
    if (cachedMntID) {
        return cachedMntID;
    }
    struct statfs sb;
    int result = syscall(345,"/",&sb);
    char *prefix = "com.apple.os.update-";
    if (result == 0 && strstr(sb.f_mntfromname, prefix)) {
        cachedMntID = [NSString stringWithFormat:@"%s", sb.f_mntfromname + strlen(prefix)];
        return cachedMntID;
    }
    return @"";
}

+ (NSString *)deviceInitTime {
    static NSString *cachedDeviceInitTime = nil;
    if (cachedDeviceInitTime) {
        return cachedDeviceInitTime;
    }
    int result = 0;
    char *path="/var/mobile";
    struct stat sb;
    result = syscall(338,path,&sb);
    struct timespec time = sb.st_birthtimespec;
    NSString *initTime = [NSString stringWithFormat:@"%ld.%09ld", time.tv_sec, time.tv_nsec];
    cachedDeviceInitTime = initTime;
    return cachedDeviceInitTime;
}

+ (nullable NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = @"ipv4";
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = @"ipv6";
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)webviewUA
{
    NSString *ua = [BDASignalManager getWebviewUA];
    if (ua.length > 0) {
        return ua;
    }
    BOOL isIpad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    return [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU %@OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", isIpad ? @"iPad" : @"iPhone", isIpad ? @"" : @"iPhone " , [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
}

#pragma mark dict转json
+ (NSString *)bda_jsonStringEncodedWithDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]] && [NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

#pragma mark url query解析
+ (NSDictionary<NSString*, NSString*> *)getQueryDictWithUrl:(NSString *)url
{
    NSString *queryString = [self getQueryStringFromString:url];
    NSArray<NSString *> *queryArray = [queryString componentsSeparatedByString:@"&"];
    return [self getQueryDictFromArr:queryArray];
}

+ (NSString *)getQueryStringFromString:(NSString *)url
{
    NSArray<NSString *> *urlComponents = [url componentsSeparatedByString:@"?"];
    if (!urlComponents || urlComponents.count < 2 || urlComponents[1].length == 0) {
        return nil;
    }
    return urlComponents[1];
}

+ (NSDictionary<NSString*, NSString*> *)getQueryDictFromArr:(NSArray<NSString *> *)queryArray
{
    NSMutableDictionary<NSString*, NSString*> *queryDict = [NSMutableDictionary new];
    for (NSString *queryItem in queryArray) {
        NSArray<NSString *> *pair = [queryItem componentsSeparatedByString:@"="];
        if (!pair
            || pair.count < 2
            || pair[0].length == 0
            || pair[1].length == 0) {
            NSRange range = [queryItem rangeOfString:@"=" options:NSLiteralSearch];
            if (range.location != NSNotFound) {
                NSString *keyString = [queryItem substringToIndex:range.location];
                NSString *valueString = [queryItem substringFromIndex:(range.location + range.length)];
                if (keyString.length > 0 && valueString.length > 0) {
                    pair = @[keyString, valueString];
                } else {
                    continue;
                }
            } else {
                continue;
            }
        }
        
        NSString *keyString = nil, *valueString = nil;
        keyString = [pair[0] stringByRemovingPercentEncoding];
        valueString = [pair[1] stringByRemovingPercentEncoding];
        if (keyString.length > 0 && valueString.length > 0) {
            [queryDict setObject:valueString forKey:keyString];
        }
    }
    
    if (queryDict.count == 0) {
        queryDict = nil;
    }
    return queryDict;
}

#pragma mark 获取公网ipv4
+ (void)getInternetIpv4WithResult:(void(^)(NSString *ipv4))result {
    NSURL *url = [NSURL URLWithString:@"https://dig.bdurl.net/q?host=analytics.oceanengine.com&f=2&aid+13"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *ipv4 = @"";
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([dict isKindOfClass:[NSDictionary class]]) {
                ipv4 = [dict objectForKey:@"cip"];
            }
        }
        if (result) {
            result(ipv4);
        }
    }];
    [task resume];
}

@end
