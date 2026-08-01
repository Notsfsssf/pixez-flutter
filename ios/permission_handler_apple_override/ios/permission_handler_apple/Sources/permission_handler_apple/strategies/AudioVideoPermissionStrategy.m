//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "AudioVideoPermissionStrategy.h"

#if PERMISSION_CAMERA | PERMISSION_MICROPHONE

@implementation AudioVideoPermissionStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    if (permission == PermissionGroupCamera) {
        #if PERMISSION_CAMERA
        return [AudioVideoPermissionStrategy permissionStatus:AVMediaTypeVideo];
        #endif
    } else if (permission == PermissionGroupMicrophone) {
        #if PERMISSION_MICROPHONE
        return [AudioVideoPermissionStrategy permissionStatus:AVMediaTypeAudio];
        #endif
    }
    return PermissionStatusDenied;
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
    completionHandler(ServiceStatusNotApplicable);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler {
    PermissionStatus status = [self checkPermissionStatus:permission];

    if (status != PermissionStatusDenied) {
        completionHandler(status);
        return;
    }

    AVMediaType mediaType;

    if (permission == PermissionGroupCamera) {
        #if PERMISSION_CAMERA
        mediaType = AVMediaTypeVideo;
        #else
        completionHandler(PermissionStatusDenied);
        return;
        #endif
    } else if (permission == PermissionGroupMicrophone) {
        #if PERMISSION_MICROPHONE
        mediaType = AVMediaTypeAudio;
        #else
        completionHandler(PermissionStatusDenied);
        return;
        #endif
    } else {
        completionHandler(PermissionStatusDenied);
        return;
    }

    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted) {
            completionHandler(PermissionStatusGranted);
        } else {
            completionHandler(PermissionStatusPermanentlyDenied);
        }
    }];
}

+ (PermissionStatus)permissionStatus:(AVMediaType const)mediaType {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            return PermissionStatusDenied;
        case AVAuthorizationStatusRestricted:
            return PermissionStatusRestricted;
        case AVAuthorizationStatusDenied:
            return PermissionStatusPermanentlyDenied;
        case AVAuthorizationStatusAuthorized:
            return PermissionStatusGranted;
    }

    return PermissionStatusDenied;
}

@end

#else

@implementation AudioVideoPermissionStrategy
@end

#endif
