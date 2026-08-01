//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "EventPermissionStrategy.h"

#if PERMISSION_EVENTS | PERMISSION_EVENTS_FULL_ACCESS | PERMISSION_REMINDERS

@implementation EventPermissionStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return [EventPermissionStrategy permissionStatus:permission];
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
    completionHandler(ServiceStatusNotApplicable);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler {
    PermissionStatus permissionStatus = [self checkPermissionStatus:permission];
    
    if (permissionStatus != PermissionStatusDenied) {
        completionHandler(permissionStatus);
        return;
    }

    if (permission == PermissionGroupCalendar || permission == PermissionGroupCalendarFullAccess) {
        if (@available(iOS 17.0, *)) {
            #if !PERMISSION_EVENTS_FULL_ACCESS
            completionHandler(PermissionStatusDenied);
            return;
            #endif
        } else {
            #if !PERMISSION_EVENTS
            completionHandler(PermissionStatusDenied);
            return;
            #endif
        }
    } else if (permission == PermissionGroupCalendarWriteOnly) {
        #if !PERMISSION_EVENTS && !PERMISSION_EVENTS_FULL_ACCESS
        completionHandler(PermissionStatusDenied);
        return;
        #endif
    } else if (permission == PermissionGroupReminders) {
        #if !PERMISSION_REMINDERS
        completionHandler(PermissionStatusDenied);
        return;
        #endif
    }

    EKEventStore *eventStore = [[EKEventStore alloc] init];

    if (@available(iOS 17.0, *)) {
        if (permission == PermissionGroupCalendar || permission == PermissionGroupCalendarFullAccess) {
            [eventStore requestFullAccessToEventsWithCompletion:^(BOOL granted, NSError *error) {
                if (granted) {
                    completionHandler(PermissionStatusGranted);
                } else {
                    completionHandler(PermissionStatusPermanentlyDenied);
                }
            }];
        } else if (permission == PermissionGroupCalendarWriteOnly) {
            [eventStore requestWriteOnlyAccessToEventsWithCompletion:^(BOOL granted, NSError *error) {
                if (granted) {
                    completionHandler(PermissionStatusGranted);
                } else {
                    completionHandler(PermissionStatusPermanentlyDenied);
                }
            }];
        } else if (permission == PermissionGroupReminders) {
            [eventStore requestFullAccessToRemindersWithCompletion:^(BOOL granted, NSError *error) {
                if (granted) {
                    completionHandler(PermissionStatusGranted);
                } else {
                    completionHandler(PermissionStatusPermanentlyDenied);
                }
            }];
        }
    } else {
        EKEntityType entityType = [EventPermissionStrategy getEntityType:permission];

        [eventStore requestAccessToEntityType:entityType completion:^(BOOL granted, NSError *error) {
            if (granted) {
                completionHandler(PermissionStatusGranted);
            } else {
                completionHandler(PermissionStatusPermanentlyDenied);
            }
        }];
    }

}

+ (PermissionStatus)permissionStatus:(PermissionGroup)permission {
    EKEntityType entityType = [EventPermissionStrategy getEntityType:permission];
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:entityType];

    if (@available(iOS 17.0, *)) {
        switch (status) {
            case EKAuthorizationStatusNotDetermined:
                return PermissionStatusDenied;
            case EKAuthorizationStatusRestricted:
                return PermissionStatusRestricted;
            case EKAuthorizationStatusDenied:
                return PermissionStatusPermanentlyDenied;
            case EKAuthorizationStatusFullAccess:
                return PermissionStatusGranted;
            case EKAuthorizationStatusWriteOnly:
                if (permission == PermissionGroupCalendarWriteOnly) {
                    return PermissionStatusGranted;
                }
                return PermissionStatusDenied;
        }
    } else {
        switch (status) {
            case EKAuthorizationStatusNotDetermined:
                return PermissionStatusDenied;
            case EKAuthorizationStatusRestricted:
                return PermissionStatusRestricted;
            case EKAuthorizationStatusDenied:
                return PermissionStatusPermanentlyDenied;
            case EKAuthorizationStatusAuthorized:
                return PermissionStatusGranted;
            case EKAuthorizationStatusWriteOnly:
                //not available on iOS 16 and below 
                break;
        }
    }
    

    
    return PermissionStatusDenied;
}

+ (EKEntityType)getEntityType:(PermissionGroup)permission {
    if (permission == PermissionGroupReminders) {
        return EKEntityTypeReminder;
    }

    return EKEntityTypeEvent;
}

@end

#else

@implementation EventPermissionStrategy
@end

#endif
