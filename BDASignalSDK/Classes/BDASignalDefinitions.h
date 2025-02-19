//
//  BDASignalDefinitions.h
//  guiyinTest
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
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventPurchase;
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKEventGameAddiction;

/**
 sdk版本号
 */
FOUNDATION_EXTERN NSString * _Nonnull const kBDADSignalSDKVersion;

@interface BDASignalDefinitions : NSObject

@end


