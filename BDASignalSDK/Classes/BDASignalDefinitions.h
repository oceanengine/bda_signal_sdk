//
//  BDASignalDefinitions.h
//
//  Created by ByteDance on 2023/7/26.
//  Copyright 2023 Beijing Ocean Engine Network Technology Co., Ltd. 
//  SPDX-License-Identifier: MIT

#import <Foundation/Foundation.h>

/**
 采集可选参数
 */
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKUserUniqueId;

/**
 关键事件
 */
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventStayTime;
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventRegister;
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventPurchase; // 广告主自主上报的付费事件
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventGameAddiction;
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventAchieveLevel; // 用户达到您在游戏中定义的某个级别
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventAddPaymentInfo; // 用户在您的应用中添加他们的付款信息，例如他们的地址或电话号码
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventAddToWishlist; // 用户在您的应用中将某件商品添加到收藏夹或愿望清单中
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventCheckout; // 用户准备在您的应用中结账订单
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventCompleteTutorial; // 用户完成您应用中的教程
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventCreateGroup; // 用户在您的游戏中创建一个群组或团队
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventCreateRole; // 用户在您的游戏中创建角色或人物
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventGenerateLead; // 用户在您的应用中留下了有价值的联系信息，例如电话号码或电子邮件
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventInAppAdClick; // 用户点击您的应用中显示的广告
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventInAppAdImpression; // 用户查看您的应用中显示的广告
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventAddToCart; // 用户将商品添加到您应用中的购物车中
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventJoinGroup; // 用户加入您游戏中的群组或团队。

/**
 sdk版本号
 */
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKVersion;

typedef enum : NSUInteger {
    kBDASignalPayStandardEventTypePay,
    kBDASignalPayStandardEventTypeClick,
    kBDASignalPayStandardEventTypeEffectPlay3,
} kBDASignalPayStandardEventType;

@interface BDASignalDefinitions : NSObject

@end


