//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionHandlerEnums.h"

typedef void (^ServiceStatusHandler)(ServiceStatus serviceStatus);
typedef void (^PermissionStatusHandler)(PermissionStatus permissionStatus);
typedef void (^PermissionErrorHandler)(NSString* errorCode, NSString* errorDescription);

@protocol PermissionStrategy <NSObject>
- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission;

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler;

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler;
@end
