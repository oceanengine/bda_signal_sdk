#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BDASignalSDK.h"
#import "BDASignalDefinitions.h"
#import "BDASignalManager.h"
#import "BDASignalUtility.h"

FOUNDATION_EXPORT double BDASignalSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char BDASignalSDKVersionString[];

