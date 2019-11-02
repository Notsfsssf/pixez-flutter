//
// Created by Razvan Lung on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "Codec.h"

@implementation Codec
+ (PermissionGroup)decodePermissionGroupFrom:(NSNumber *)event {
    return (PermissionGroup) event.intValue;
}

+ (NSArray *_Nullable)decodePermissionGroupsFrom:(NSArray<NSNumber *> *)event {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSNumber *number in event) {
        [result addObject:@([self decodePermissionGroupFrom:number])];
    }
    return [[NSArray alloc] initWithArray:result];
}

+ (NSNumber *_Nullable)encodePermissionStatus:(enum PermissionStatus)permissionStatus {
    return [[NSNumber alloc] initWithInt:permissionStatus];
}

+ (NSNumber *_Nullable)encodeServiceStatus:(enum ServiceStatus)serviceStatus {
    return [[NSNumber alloc] initWithInt:serviceStatus];
}

@end
