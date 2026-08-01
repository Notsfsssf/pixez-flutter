//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "SensorPermissionStrategy.h"

#if PERMISSION_SENSORS

@implementation SensorPermissionStrategy
- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return [SensorPermissionStrategy permissionStatus];
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
    completionHandler([CMMotionActivityManager isActivityAvailable]
        ? ServiceStatusEnabled
        : ServiceStatusDisabled
    );
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler {
    PermissionStatus status = [self checkPermissionStatus:permission];
    
    if (status != PermissionStatusDenied) {
        completionHandler(status);
        return;
    }
    
    CMMotionActivityManager *motionManager = [[CMMotionActivityManager alloc] init];
    
    NSDate *today = [NSDate new];
    [motionManager queryActivityStartingFromDate:today toDate:today toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray<CMMotionActivity *> *__nullable activities, NSError *__nullable error) {
        PermissionStatus status = [SensorPermissionStrategy permissionStatus];
        completionHandler(status);
    }];

}

+ (PermissionStatus)permissionStatus {
    CMAuthorizationStatus status = [CMMotionActivityManager authorizationStatus];
    PermissionStatus permissionStatus;
    
    switch (status) {
        case CMAuthorizationStatusNotDetermined:
            permissionStatus = PermissionStatusDenied;
            break;
        case CMAuthorizationStatusRestricted:
            permissionStatus = PermissionStatusRestricted;
            break;
        case CMAuthorizationStatusDenied:
            permissionStatus = PermissionStatusPermanentlyDenied;
            break;
        case CMAuthorizationStatusAuthorized:
            permissionStatus = PermissionStatusGranted;
            break;
        default:
            permissionStatus = PermissionStatusGranted;
    }
    
    return permissionStatus;
}

@end

#else

@implementation SensorPermissionStrategy
@end

#endif
