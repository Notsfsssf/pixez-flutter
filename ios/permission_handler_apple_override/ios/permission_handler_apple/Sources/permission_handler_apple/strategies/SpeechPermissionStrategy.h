//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_SPEECH_RECOGNIZER

#import <Speech/Speech.h>

@interface SpeechPermissionStrategy : NSObject <PermissionStrategy>
@end

#else

#import "UnknownPermissionStrategy.h"
@interface SpeechPermissionStrategy : UnknownPermissionStrategy
@end

#endif
