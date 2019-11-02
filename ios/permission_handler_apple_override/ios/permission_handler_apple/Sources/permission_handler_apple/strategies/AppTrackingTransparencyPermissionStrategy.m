//
//  AppTrackingTransparency.m
//  permission_handler
//
//  Created by Jan-Derk on 21/05/2021.
//

#import "AppTrackingTransparencyPermissionStrategy.h"

#if PERMISSION_APP_TRACKING_TRANSPARENCY

@implementation AppTrackingTransparencyPermissionStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    if (@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus attPermission = [ATTrackingManager trackingAuthorizationStatus];
        return [AppTrackingTransparencyPermissionStrategy parsePermission:attPermission];
    }
    
    return PermissionStatusGranted;
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
    completionHandler(ServiceStatusNotApplicable);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler{
    PermissionStatus status = [self checkPermissionStatus:permission];
    if (status != PermissionStatusDenied) {
        completionHandler(status);
        return;
    }
    
    if (@available(iOS 14, *)){
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            PermissionStatus permissionStatus = [AppTrackingTransparencyPermissionStrategy parsePermission:status];
            completionHandler(permissionStatus);
        }];
    } else {
        completionHandler(PermissionStatusGranted);
    }
}

+ (PermissionStatus)parsePermission:(ATTrackingManagerAuthorizationStatus)attPermission API_AVAILABLE(ios(14)){
    switch(attPermission){
        case ATTrackingManagerAuthorizationStatusAuthorized:
            return PermissionStatusGranted;
        case ATTrackingManagerAuthorizationStatusRestricted:
            return PermissionStatusRestricted;
        case ATTrackingManagerAuthorizationStatusDenied:
            return PermissionStatusPermanentlyDenied;
        case ATTrackingManagerAuthorizationStatusNotDetermined:
            return PermissionStatusDenied;
    }
}
@end

#else

@implementation AppTrackingTransparencyPermissionStrategy
@end

#endif

