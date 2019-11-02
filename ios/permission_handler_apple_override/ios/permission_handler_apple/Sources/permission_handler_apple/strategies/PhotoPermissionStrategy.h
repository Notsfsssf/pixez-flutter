//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_PHOTOS

#import <Photos/Photos.h>

@interface PhotoPermissionStrategy : NSObject <PermissionStrategy>
-(instancetype)initWithAccessAddOnly:(BOOL) addOnly;
@end

#else

#import "UnknownPermissionStrategy.h"
@interface PhotoPermissionStrategy : UnknownPermissionStrategy
@end

#endif
