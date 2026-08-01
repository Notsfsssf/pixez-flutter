//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "PhotoPermissionStrategy.h"

#if PERMISSION_PHOTOS

@implementation PhotoPermissionStrategy{
    bool addOnlyAccessLevel;
}

- (instancetype)initWithAccessAddOnly:(BOOL)addOnly {
    self = [super init];
    if(self) {
        addOnlyAccessLevel = addOnly;
    }
    
    return self;
}

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return [PhotoPermissionStrategy permissionStatus:addOnlyAccessLevel];
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

    if(@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:(addOnlyAccessLevel)?PHAccessLevelAddOnly:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus authorizationStatus) {
            completionHandler([PhotoPermissionStrategy determinePermissionStatus:authorizationStatus]);
        }];
    }else {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
        completionHandler([PhotoPermissionStrategy determinePermissionStatus:authorizationStatus]);
    }];
    }
}

+ (PermissionStatus)permissionStatus:(BOOL) addOnlyAccessLevel {
    PHAuthorizationStatus status;
    if(@available(iOS 14, *)){
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:(addOnlyAccessLevel)?PHAccessLevelAddOnly:PHAccessLevelReadWrite];
    }else {
        status = [PHPhotoLibrary authorizationStatus];
    }

    return [PhotoPermissionStrategy determinePermissionStatus:status];
}

+ (PermissionStatus)determinePermissionStatus:(PHAuthorizationStatus)authorizationStatus {
    switch (authorizationStatus) {
        case PHAuthorizationStatusNotDetermined:
            return PermissionStatusDenied;
        case PHAuthorizationStatusRestricted:
            return PermissionStatusRestricted;
        case PHAuthorizationStatusDenied:
            return PermissionStatusPermanentlyDenied;
        case PHAuthorizationStatusAuthorized:
            return PermissionStatusGranted;
        case PHAuthorizationStatusLimited:
            return PermissionStatusLimited;
    }

    return PermissionStatusDenied;
}

@end

#else

@implementation PhotoPermissionStrategy
@end

#endif
