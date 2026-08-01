//
//  CriticalAlertsPermissionStrategy.m
//  permission_handler
//
//  Created by Neal Soni on 2021/6/8.
//

#import "CriticalAlertsPermissionStrategy.h"

#if PERMISSION_CRITICAL_ALERTS

@implementation CriticalAlertsPermissionStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
  return [CriticalAlertsPermissionStrategy permissionStatus];
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
  dispatch_async(dispatch_get_main_queue(), ^{
    if(@available(iOS 12.0, *)) {
      UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
      UNAuthorizationOptions authorizationOptions = 0;
      authorizationOptions += UNAuthorizationOptionCriticalAlert;
      [center requestAuthorizationWithOptions:(authorizationOptions) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error != nil || !granted) {
          completionHandler(PermissionStatusPermanentlyDenied);
          return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            completionHandler(PermissionStatusGranted);
        });
      }];
    } else {
      completionHandler(PermissionStatusPermanentlyDenied);
    }
  });
}

+ (PermissionStatus)permissionStatus {
  __block PermissionStatus permissionStatus = PermissionStatusGranted;
  if (@available(iOS 12 , *)) {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
      if (settings.criticalAlertSetting == UNAuthorizationStatusDenied) {
        permissionStatus = PermissionStatusPermanentlyDenied;
      } else if (settings.criticalAlertSetting == UNAuthorizationStatusNotDetermined) {
        permissionStatus = PermissionStatusDenied;
      }
      dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  } else {
    permissionStatus = PermissionStatusPermanentlyDenied;
  }

  return permissionStatus;
}

@end

#else

@implementation CriticalAlertsPermissionStrategy
@end

#endif
