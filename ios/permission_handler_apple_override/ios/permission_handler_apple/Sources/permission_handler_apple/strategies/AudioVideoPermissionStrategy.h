//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_CAMERA | PERMISSION_MICROPHONE
#import <AVFoundation/AVFoundation.h>

@interface AudioVideoPermissionStrategy : NSObject <PermissionStrategy>
@end

#else

#import "UnknownPermissionStrategy.h"
@interface AudioVideoPermissionStrategy : UnknownPermissionStrategy
@end

#endif
