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
 获取idfv
 */
+ (NSString *)idfv;

/**
 获取idfa
 */
+ (NSString *)idfa;

/**
 获取系统更新时间
 */
+ (NSString *)systemFileTime;

/**
 获取设备名称
 */
+ (NSString *)deviceName;

/**
 获取设备型号
 */
+ (NSString *)deviceModel;

/**
 获取硬件型号
 */
+ (NSString *)hardwareModel;

/**
 获取系统启动时间
 */
+ (NSString *)systemBootTime;

/**
 获取系统版本
 */
+ (NSString *)systemVersion;

/**
 获取系统内存大小
 */
+ (NSString *)systemMemorySize;

/**
 获取系统硬盘大小
 */
+ (NSString *)systemDiskSize;

/**
 获取挂载ID
 */
+ (NSString *)mntID;

/**
 获取设备初始化时间
 */
+ (NSString *)deviceInitTime;

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


