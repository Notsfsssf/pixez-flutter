//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_EVENTS | PERMISSION_EVENTS_FULL_ACCESS | PERMISSION_REMINDERS

#import <EventKit/EventKit.h>

@interface EventPermissionStrategy : NSObject <PermissionStrategy>
@end

#else

#import "UnknownPermissionStrategy.h"
@interface EventPermissionStrategy : UnknownPermissionStrategy
@end

#endif
