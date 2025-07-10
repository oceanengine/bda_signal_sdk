//
//  BDASignalManager.h
//
//  Created by ByteDance on 2023/7/26.
//  Copyright 2023 Beijing Ocean Engine Network Technology Co., Ltd. 
//  SPDX-License-Identifier: MIT

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>
#import "BDASignalDefinitions.h"

typedef void(^BDASignalEventUploadCallback)(NSDictionary * _Nullable result);

@interface BDASignalManager : NSObject

/**
 单例
 */
+ (instancetype _Nonnull )sharedInstance;

/**
 SDK初始化，并传入可选参数
 */
+ (void)registerWithOptionalData:(NSDictionary *_Nullable)config;

/**
  上报冷启动事件
 */
+ (void)didFinishLaunchingWithOptions:(NSDictionary *_Nullable)launchOptions connectOptions:(UISceneConnectionOptions *_Nullable)connetOptions;

/**
 解析openurl中的clickid
 */
+ (NSString *_Nullable)anylyseDeeplinkClickidWithOpenUrl:(NSString *_Nullable)openUrl;

/**
 上报关键事件
 */
+ (void)trackEssentialEventWithName:(NSString *_Nullable)key params:(NSDictionary *_Nullable)params;

/**
 获取clickid
 */
+ (NSString *_Nullable)getClickId;

/**
 获取clickid
 */
+ (NSString *_Nullable)getCacheOpenUrl;

/**
 获取用户注入的额外信息
 */
+ (NSDictionary *_Nullable)getExtraParams;

/**
 获取ipv4
 */
+ (NSString *_Nullable)getIpv4;

/**
 获取webview UA
 */
+ (NSString *_Nullable)getWebviewUA;

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
 注册事件上报回调
 */
+ (void)registerEventUploadCallback:(BDASignalEventUploadCallback)callback;

/**
 触发注册事件上报回调
 */
+ (void)handleEventUploadResult:(NSDictionary *_Nullable)result;

/**
 clickid
 */
@property (nonatomic, copy) NSString * _Nullable clickid;

/**
 接入放需要上报的额外信息
 */
@property (nonatomic, strong) NSMutableDictionary * _Nullable extraParam;

@end


