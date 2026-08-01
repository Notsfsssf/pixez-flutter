//
//  BackgroundRefreshStrategy.m
//  permission_handler_apple
//
//  Created by Sebastian Roth on 28/09/2023.
//

#import "BackgroundRefreshStrategy.h"

@implementation BackgroundRefreshStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission { 
    return [BackgroundRefreshStrategy permissionStatus];
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler { 
    completionHandler(ServiceStatusNotApplicable);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler { 
    completionHandler([BackgroundRefreshStrategy permissionStatus]);
}

+ (PermissionStatus) permissionStatus {
    UIBackgroundRefreshStatus status = UIApplication.sharedApplication.backgroundRefreshStatus;
    switch (status) {
        case UIBackgroundRefreshStatusDenied:
            return PermissionStatusDenied;
        case UIBackgroundRefreshStatusRestricted:
            return PermissionStatusRestricted;
        case UIBackgroundRefreshStatusAvailable:
            return PermissionStatusGranted;
        default:
            return PermissionStatusDenied;
    }
}

@end
