//
// Created by Razvan Lung on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionHandlerEnums.h"

@interface Codec : NSObject
+ (PermissionGroup)decodePermissionGroupFrom:(NSNumber *_Nonnull)event;

+ (NSArray*_Nullable)decodePermissionGroupsFrom:(NSArray<NSNumber *> *_Nullable)event;

+ (NSNumber *_Nullable)encodePermissionStatus:(enum PermissionStatus)permissionStatus;

+ (NSNumber *_Nullable)encodeServiceStatus:(enum ServiceStatus)serviceStatus;
@end
