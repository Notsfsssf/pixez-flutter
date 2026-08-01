//
//  NotificationPermissionStrategy.m
//  permission_handler
//
//  Created by Tong on 2019/10/21.
//

#import "NotificationPermissionStrategy.h"

#if PERMISSION_NOTIFICATIONS

@implementation NotificationPermissionStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
  return [NotificationPermissionStrategy permissionStatus];
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
    completionHandler(ServiceStatusNotApplicable);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler  errorHandler:(PermissionErrorHandler)errorHandler {
  PermissionStatus status = [self checkPermissionStatus:permission];
  if (@available(iOS 12.0, *)) {
    if (status != PermissionStatusDenied && status != PermissionStatusProvisional) {
      completionHandler(status);
      return;
    }
  } else if (status != PermissionStatusDenied) {
    completionHandler(status);
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions authorizationOptions = 0;
    authorizationOptions += UNAuthorizationOptionSound;
    authorizationOptions += UNAuthorizationOptionAlert;
    authorizationOptions += UNAuthorizationOptionBadge;
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
  });
}

+ (PermissionStatus)permissionStatus {
  __block PermissionStatus permissionStatus = PermissionStatusGranted;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    if (@available(iOS 12 , *) && settings.authorizationStatus == UNAuthorizationStatusProvisional) {
      permissionStatus = PermissionStatusProvisional;
    } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
      permissionStatus = PermissionStatusPermanentlyDenied;
    } else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
      permissionStatus = PermissionStatusDenied;
    }
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  return permissionStatus;
}

@end

#else

@implementation NotificationPermissionStrategy
@end

#endif
