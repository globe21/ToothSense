/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

///--------------------------------------
#pragma mark - SDK Version
///--------------------------------------

#define PARSE_VERSION @"1.14.2"

///--------------------------------------
#pragma mark - Platform
///--------------------------------------

extern NSString *const _Nonnull kPFDeviceType;

///--------------------------------------
#pragma mark - Cache Policies
///--------------------------------------

/**
 `PFCachePolicy` specifies different caching policies that could be used with `PFQuery`.

 This lets you show data when the user's device is offline,
 or when the app has just started and network requests have not yet had time to complete.
 Parse takes care of automatically flushing the cache when it takes up too much space.

 @warning Cache policy could only be set when Local Datastore is not enabled.
*/
///--------------------------------------
#pragma mark - Blocks
///--------------------------------------

@class PFObject;
@class PFUser;

typedef void (^PFBooleanResultBlock)(BOOL succeeded, NSError *_Nullable error);
typedef void (^PFIntegerResultBlock)(int number, NSError *_Nullable error);
typedef void (^PFArrayResultBlock)(NSArray *_Nullable objects, NSError *_Nullable error);
typedef void (^PFObjectResultBlock)(PFObject *_Nullable object,  NSError *_Nullable error);
typedef void (^PFSetResultBlock)(NSSet *_Nullable channels, NSError *_Nullable error);
typedef void (^PFUserResultBlock)(PFUser *_Nullable user, NSError *_Nullable error);
typedef void (^PFDataResultBlock)(NSData *_Nullable data, NSError *_Nullable error);
typedef void (^PFDataStreamResultBlock)(NSInputStream *_Nullable stream, NSError *_Nullable error);
typedef void (^PFFilePathResultBlock)(NSString *_Nullable filePath, NSError *_Nullable error);
typedef void (^PFStringResultBlock)(NSString *_Nullable string, NSError *_Nullable error);
typedef void (^PFIdResultBlock)(_Nullable id object, NSError *_Nullable error);
typedef void (^PFProgressBlock)(int percentDone);

///--------------------------------------
#pragma mark - Network Notifications
///--------------------------------------


/**
 The name of the notification that is going to be sent before any URL request is sent.
 */
extern NSString *const _Nonnull PFNetworkWillSendURLRequestNotification;

/**
 The name of the notification that is going to be sent after any URL response is received.
 */
extern NSString *const _Nonnull PFNetworkDidReceiveURLResponseNotification;

/**
 The key of request(NSURLRequest) in the userInfo dictionary of a notification.
 @note This key is populated in userInfo, only if `PFLogLevel` on `Parse` is set to `PFLogLevelDebug`.
 */
extern NSString *const _Nonnull PFNetworkNotificationURLRequestUserInfoKey;

/**
 The key of response(NSHTTPURLResponse) in the userInfo dictionary of a notification.
 @note This key is populated in userInfo, only if `PFLogLevel` on `Parse` is set to `PFLogLevelDebug`.
 */
extern NSString *const _Nonnull PFNetworkNotificationURLResponseUserInfoKey;

/**
 The key of repsonse body (usually `NSString` with JSON) in the userInfo dictionary of a notification.
 @note This key is populated in userInfo, only if `PFLogLevel` on `Parse` is set to `PFLogLevelDebug`.
 */
extern NSString *const _Nonnull PFNetworkNotificationURLResponseBodyUserInfoKey;


///--------------------------------------
#pragma mark - Deprecated Macros
///--------------------------------------

#ifndef PARSE_DEPRECATED
#  ifdef __deprecated_msg
#    define PARSE_DEPRECATED(_MSG) __deprecated_msg(_MSG)
#  else
#    ifdef __deprecated
#      define PARSE_DEPRECATED(_MSG) __attribute__((deprecated))
#    else
#      define PARSE_DEPRECATED(_MSG)
#    endif
#  endif
#endif

///--------------------------------------
#pragma mark - Extensions Macros
///--------------------------------------

#ifndef PF_EXTENSION_UNAVAILABLE
#  if PARSE_IOS_ONLY
#    ifdef NS_EXTENSION_UNAVAILABLE_IOS
#      define PF_EXTENSION_UNAVAILABLE(_msg) NS_EXTENSION_UNAVAILABLE_IOS(_msg)
#    else
#      define PF_EXTENSION_UNAVAILABLE(_msg)
#    endif
#  else
#    ifdef NS_EXTENSION_UNAVAILABLE_MAC
#      define PF_EXTENSION_UNAVAILABLE(_msg) NS_EXTENSION_UNAVAILABLE_MAC(_msg)
#    else
#      define PF_EXTENSION_UNAVAILABLE(_msg)
#    endif
#  endif
#endif

///--------------------------------------
#pragma mark - Swift Macros
///--------------------------------------

#ifndef PF_SWIFT_UNAVAILABLE
#  ifdef NS_SWIFT_UNAVAILABLE
#    define PF_SWIFT_UNAVAILABLE NS_SWIFT_UNAVAILABLE("")
#  else
#    define PF_SWIFT_UNAVAILABLE
#  endif
#endif

///--------------------------------------
#pragma mark - Platform Availability Defines
///--------------------------------------

#ifndef TARGET_OS_IOS
#  define TARGET_OS_IOS TARGET_OS_IPHONE
#endif
#ifndef TARGET_OS_WATCH
#  define TARGET_OS_WATCH 0
#endif
#ifndef TARGET_OS_TV
#  define TARGET_OS_TV 0
#endif

#ifndef PF_TARGET_OS_OSX
#  define PF_TARGET_OS_OSX (TARGET_OS_MAC && !TARGET_OS_IOS && !TARGET_OS_WATCH && !TARGET_OS_TV)
#endif

///--------------------------------------
#pragma mark - Avaiability Macros
///--------------------------------------

#ifndef PF_IOS_UNAVAILABLE
#  ifdef __IOS_UNAVILABLE
#    define PF_IOS_UNAVAILABLE __IOS_UNAVAILABLE
#  else
#    define PF_IOS_UNAVAILABLE
#  endif
#endif

#ifndef PF_IOS_UNAVAILABLE_WARNING
#  if TARGET_OS_IOS
#    define PF_IOS_UNAVAILABLE_WARNING _Pragma("GCC warning \"This file is unavailable on iOS.\"")
#  else
#    define PF_IOS_UNAVAILABLE_WARNING
#  endif
#endif

#ifndef PF_OSX_UNAVAILABLE
#  if PF_TARGET_OS_OSX
#    define PF_OSX_UNAVAILABLE __OSX_UNAVAILABLE
#  else
#    define PF_OSX_UNAVAILABLE
#  endif
#endif

#ifndef PF_OSX_UNAVAILABLE_WARNING
#  if PF_TARGET_OS_OSX
#    define PF_OSX_UNAVAILABLE_WARNING _Pragma("GCC warning \"This file is unavailable on OS X.\"")
#  else
#    define PF_OSX_UNAVAILABLE_WARNING
#  endif
#endif

#ifndef PF_WATCH_UNAVAILABLE
#  ifdef __WATCHOS_UNAVAILABLE
#    define PF_WATCH_UNAVAILABLE __WATCHOS_UNAVAILABLE
#  else
#    define PF_WATCH_UNAVAILABLE
#  endif
#endif

#ifndef PF_WATCH_UNAVAILABLE_WARNING
#  if TARGET_OS_WATCH
#    define PF_WATCH_UNAVAILABLE_WARNING _Pragma("GCC warning \"This file is unavailable on watchOS.\"")
#  else
#    define PF_WATCH_UNAVAILABLE_WARNING
#  endif
#endif

#ifndef PF_TV_UNAVAILABLE
#  ifdef __TVOS_PROHIBITED
#    define PF_TV_UNAVAILABLE __TVOS_PROHIBITED
#  else
#    define PF_TV_UNAVAILABLE
#  endif
#endif

#ifndef PF_TV_UNAVAILABLE_WARNING
#  if TARGET_OS_TV
#    define PF_TV_UNAVAILABLE_WARNING _Pragma("GCC warning \"This file is unavailable on tvOS.\"")
#  else
#    define PF_TV_UNAVAILABLE_WARNING
#  endif
#endif
