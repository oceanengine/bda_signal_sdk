//
//  BDASignalUtility.h
//  工具方法负责参数采集
//
//  Created by ByteDance on 2023/7/26.
//  Copyright 2023 Beijing Ocean Engine Network Technology Co., Ltd. 
//  SPDX-License-Identifier: MIT

#import <Foundation/Foundation.h>


@interface BDASignalUtility : NSObject

/**
 发送网络请求
 */
+ (void)requestSignalWithParams:(NSDictionary *)params;

// 获取必选参数方法
/**
 获取ip列表
 */
+ (NSDictionary *)getIPAddresses;

/**
 获取UA
 */
+ (NSString *)webviewUA;

// 工具方法
/**
 字典转string
 */
+ (NSString *)bda_jsonStringEncodedWithDict:(NSDictionary *)dict;

/**
 解析url中的query
 */
+ (NSDictionary<NSString*, NSString*> *)getQueryDictWithUrl:(NSString *)url;

/**
 获取公网ipv4
 */
+ (void)getInternetIpv4WithResult:(void(^)(NSString *ipv4))result;

@end


