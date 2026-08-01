//
//  StoragePermissionStrategy.m
//  permission_handler
//
//  Created by Frank Gregor on 06.11.19.
//

#import "StoragePermissionStrategy.h"

@implementation StoragePermissionStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return [StoragePermissionStrategy permissionStatus];
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
    completionHandler(ServiceStatusNotApplicable);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler {
    completionHandler([StoragePermissionStrategy permissionStatus]);
}

+ (PermissionStatus)permissionStatus {
    return PermissionStatusGranted;
}

@end
