//
// Created by Baptiste Dupuch(dupuchba) on 2023-09-04.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_ASSISTANT

#import <Intents/Intents.h>

@interface AssistantPermissionStrategy : NSObject <PermissionStrategy>
@end

#else

#import "UnknownPermissionStrategy.h"
@interface AssistantPermissionStrategy : UnknownPermissionStrategy
@end

#endif
