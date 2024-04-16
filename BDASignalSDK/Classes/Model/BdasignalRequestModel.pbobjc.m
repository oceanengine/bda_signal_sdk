// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: BDASignalRequestModel.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "BdasignalRequestModel.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#pragma mark - Objective C Class declarations
// Forward declarations of Objective C classes that we can use as
// static values in struct initializers.
// We don't use [Foo class] because it is not a static value.
GPBObjCClassDeclaration(BDASignalHeader);
GPBObjCClassDeclaration(BDASignalUser);

#pragma mark - BDASignalBdasignalRequestModelRoot

@implementation BDASignalBdasignalRequestModelRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - BDASignalBdasignalRequestModelRoot_FileDescriptor

static GPBFileDescriptor *BDASignalBdasignalRequestModelRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                 objcPrefix:@"BDASignal"
                                                     syntax:GPBFileSyntaxProto2];
  }
  return descriptor;
}

#pragma mark - BDASignalEvent

@implementation BDASignalEvent

@dynamic hasUser, user;
@dynamic hasHeader, header;
@dynamic hasEventName, eventName;
@dynamic hasParams, params;
@dynamic hasLocalTime, localTime;
@dynamic hasServerTime, serverTime;

typedef struct BDASignalEvent__storage_ {
  uint32_t _has_storage_[1];
  BDASignalUser *user;
  BDASignalHeader *header;
  NSString *eventName;
  NSString *params;
  NSString *localTime;
  NSString *serverTime;
} BDASignalEvent__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "user",
        .dataTypeSpecific.clazz = GPBObjCClass(BDASignalUser),
        .number = BDASignalEvent_FieldNumber_User,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(BDASignalEvent__storage_, user),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "header",
        .dataTypeSpecific.clazz = GPBObjCClass(BDASignalHeader),
        .number = BDASignalEvent_FieldNumber_Header,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(BDASignalEvent__storage_, header),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "eventName",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalEvent_FieldNumber_EventName,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(BDASignalEvent__storage_, eventName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "params",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalEvent_FieldNumber_Params,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(BDASignalEvent__storage_, params),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "localTime",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalEvent_FieldNumber_LocalTime,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(BDASignalEvent__storage_, localTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "serverTime",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalEvent_FieldNumber_ServerTime,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(BDASignalEvent__storage_, serverTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BDASignalEvent class]
                                     rootClass:[BDASignalBdasignalRequestModelRoot class]
                                          file:BDASignalBdasignalRequestModelRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(BDASignalEvent__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - BDASignalUser

@implementation BDASignalUser

@dynamic hasUserUniqueId, userUniqueId;
@dynamic hasUserId, userId;

typedef struct BDASignalUser__storage_ {
  uint32_t _has_storage_[1];
  NSString *userUniqueId;
  NSString *userId;
} BDASignalUser__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "userUniqueId",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalUser_FieldNumber_UserUniqueId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(BDASignalUser__storage_, userUniqueId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "userId",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalUser_FieldNumber_UserId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(BDASignalUser__storage_, userId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BDASignalUser class]
                                     rootClass:[BDASignalBdasignalRequestModelRoot class]
                                          file:BDASignalBdasignalRequestModelRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(BDASignalUser__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - BDASignalHeader

@implementation BDASignalHeader

@dynamic hasAppPackage, appPackage;
@dynamic hasAppVersion, appVersion;
@dynamic hasDeviceName, deviceName;
@dynamic hasDeviceModel, deviceModel;
@dynamic hasModel, model;
@dynamic hasBootTimeSec, bootTimeSec;
@dynamic hasSystemVersion, systemVersion;
@dynamic hasMemory, memory;
@dynamic hasDisk, disk;
@dynamic hasDeviceMntId, deviceMntId;
@dynamic hasDeviceInitTime, deviceInitTime;
@dynamic hasSysFileTime, sysFileTime;
@dynamic hasClientTun, clientTun;
@dynamic hasClientAnpi, clientAnpi;
@dynamic hasUserAgent, userAgent;
@dynamic hasIpv4, ipv4;
@dynamic hasIpv6, ipv6;
@dynamic hasClickId, clickId;
@dynamic hasIdfa, idfa;
@dynamic hasIdfv, idfv;
@dynamic hasSdkVersion, sdkVersion;
@dynamic hasDeeplink, deeplink;

typedef struct BDASignalHeader__storage_ {
  uint32_t _has_storage_[1];
  NSString *appPackage;
  NSString *appVersion;
  NSString *deviceName;
  NSString *deviceModel;
  NSString *model;
  NSString *bootTimeSec;
  NSString *systemVersion;
  NSString *memory;
  NSString *disk;
  NSString *deviceMntId;
  NSString *deviceInitTime;
  NSString *sysFileTime;
  NSString *clientTun;
  NSString *clientAnpi;
  NSString *userAgent;
  NSString *ipv4;
  NSString *ipv6;
  NSString *clickId;
  NSString *idfa;
  NSString *idfv;
  NSString *sdkVersion;
  NSString *deeplink;
} BDASignalHeader__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "appPackage",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_AppPackage,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, appPackage),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "appVersion",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_AppVersion,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, appVersion),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceName",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_DeviceName,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, deviceName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceModel",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_DeviceModel,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, deviceModel),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "model",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Model,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, model),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "bootTimeSec",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_BootTimeSec,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, bootTimeSec),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "systemVersion",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_SystemVersion,
        .hasIndex = 6,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, systemVersion),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "memory",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Memory,
        .hasIndex = 7,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, memory),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "disk",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Disk,
        .hasIndex = 8,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, disk),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceMntId",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_DeviceMntId,
        .hasIndex = 9,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, deviceMntId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceInitTime",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_DeviceInitTime,
        .hasIndex = 10,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, deviceInitTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "sysFileTime",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_SysFileTime,
        .hasIndex = 11,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, sysFileTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "clientTun",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_ClientTun,
        .hasIndex = 12,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, clientTun),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "clientAnpi",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_ClientAnpi,
        .hasIndex = 13,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, clientAnpi),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "userAgent",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_UserAgent,
        .hasIndex = 14,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, userAgent),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "ipv4",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Ipv4,
        .hasIndex = 15,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, ipv4),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "ipv6",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Ipv6,
        .hasIndex = 16,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, ipv6),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "clickId",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_ClickId,
        .hasIndex = 17,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, clickId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "idfa",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Idfa,
        .hasIndex = 18,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, idfa),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "idfv",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Idfv,
        .hasIndex = 19,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, idfv),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "sdkVersion",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_SdkVersion,
        .hasIndex = 20,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, sdkVersion),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deeplink",
        .dataTypeSpecific.clazz = Nil,
        .number = BDASignalHeader_FieldNumber_Deeplink,
        .hasIndex = 21,
        .offset = (uint32_t)offsetof(BDASignalHeader__storage_, deeplink),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BDASignalHeader class]
                                     rootClass:[BDASignalBdasignalRequestModelRoot class]
                                          file:BDASignalBdasignalRequestModelRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(BDASignalHeader__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
