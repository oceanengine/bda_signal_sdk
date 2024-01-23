//
//  BDASignalManager.h
//  guiyinTest
//
//  Created by ByteDance on 2023/7/26.
//  Copyright 2023 Beijing Ocean Engine Network Technology Co., Ltd. 
//  SPDX-License-Identifier: MIT

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>
#import "BDASignalDefinitions.h"

@interface BDASignalManager : NSObject

/**
 单例
 */
+ (instancetype)sharedInstance;

/**
 SDK初始化，并传入可选参数
 */
+ (void)registerWithOptionalData:(NSDictionary *)config;

/**
  上报冷启动事件
 */
+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions connectOptions:(UISceneConnectionOptions *)connetOptions;

/**
 解析openurl中的clickid
 */
+ (NSString *)anylyseDeeplinkClickidWithOpenUrl:(NSString *)openUrl;

/**
 上报关键事件
 */
+ (void)trackEssentialEventWithName:(NSString *)key params:(NSDictionary *)params;

/**
 获取clickid
 */
+ (NSString *)getClickId;

/**
 获取clickid
 */
+ (NSString *)getCacheOpenUrl;

/**
 获取用户注入的额外信息
 */
+ (NSDictionary *)getExtraParams;

/**
 获取ipv4
 */
+ (NSString *)getIpv4;

/**
 获取webview UA
 */
+ (NSString *)getWebviewUA;

/**
 是否允许采集idfa
 */
+ (void)enableIdfa:(BOOL)enable;

/**
 获取idfa开关状态
 */
+ (BOOL)getIdfaStatus;

/**
 开启延时上报 配合下方允许上报按钮使用
 主要用户需要同意隐私协议等场景
 */
+ (void)enableDelayUpload;

/**
 允许上报，配合上方开启延时上报功能使用
 */
+ (void)startSendingEvents;

/**
 clickid
 */
@property (nonatomic, copy) NSString *clickid;

/**
 接入放需要上报的额外信息
 */
@property (nonatomic, strong) NSMutableDictionary *extraParam;

@end


