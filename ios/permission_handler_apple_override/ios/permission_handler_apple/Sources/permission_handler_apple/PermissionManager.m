//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "PermissionManager.h"

@implementation PermissionManager {
    NSMutableArray <id <PermissionStrategy>> *_strategyInstances;
}

- (instancetype)initWithStrategyInstances {
    self = [super init];
    if (self) {
        _strategyInstances = _strategyInstances = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+ (void)checkPermissionStatus:(enum PermissionGroup)permission result:(FlutterResult)result {
    id <PermissionStrategy> permissionStrategy = [PermissionManager createPermissionStrategy:permission];
    PermissionStatus status = [permissionStrategy checkPermissionStatus:permission];
    
    result([Codec encodePermissionStatus:status]);
}

+ (void)checkServiceStatus:(enum PermissionGroup)permission result:(FlutterResult)result {
    __block id <PermissionStrategy> permissionStrategy = [PermissionManager createPermissionStrategy:permission];
    
    [permissionStrategy checkServiceStatus:permission completionHandler:^(ServiceStatus serviceStatus) {
        result([Codec encodeServiceStatus:serviceStatus]);
        
        // Make sure `result` is called before cleaning up the reference
        // otherwise the `result` block is also dereferenced on iOS 12 and
        // below (this is most likely a bug in Objective-C which is solved in the
        // later versions of the runtime).
        permissionStrategy = nil;
    }];
}

- (void)requestPermissions:(NSArray *)permissions completion:(PermissionRequestCompletion)completion errorHandler:(PermissionErrorHandler)errorHandler {
    NSMutableDictionary *permissionStatusResult = [[NSMutableDictionary alloc] init];

    if (permissions.count == 0) {
        completion(permissionStatusResult);
        return;
    }
    
    NSMutableSet *requestQueue = [[NSMutableSet alloc] initWithArray:permissions];
        
    for (int i = 0; i < permissions.count; ++i) {
        NSNumber *rawNumberValue = permissions[i];
        int rawValue = rawNumberValue.intValue;
        PermissionGroup permission = (PermissionGroup) rawValue;
        
        __block id <PermissionStrategy> permissionStrategy = [PermissionManager createPermissionStrategy:permission];
        [_strategyInstances addObject:permissionStrategy];
        
        [permissionStrategy requestPermission:permission completionHandler:^(PermissionStatus permissionStatus) {
            permissionStatusResult[@(permission)] = @(permissionStatus);
            [requestQueue removeObject:@(permission)];
                
            [self->_strategyInstances removeObject:permissionStrategy];
                
            if (requestQueue.count == 0) {
                completion(permissionStatusResult);
            }
                
            // Make sure `completion` is called before cleaning up the reference
            // otherwise the `completion` block is also dereferenced on iOS 12 and
            // below (this is most likely a bug in Objective-C which is solved in
            // later versions of the runtime).
            permissionStrategy = nil;
        } errorHandler: ^(NSString* errorCode, NSString* errorDesciption) {
            errorHandler(errorCode, errorDesciption);
            permissionStrategy = nil;
        }];
    }
}

+ (void)openAppSettings:(FlutterResult)result {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                       options:[[NSDictionary alloc] init]
                             completionHandler:^(BOOL success) {
                                 result([[NSNumber alloc] initWithBool:success]);
                             }];
}

+ (id)createPermissionStrategy:(PermissionGroup)permission {
    switch (permission) {
        case PermissionGroupCalendar:
        case PermissionGroupCalendarWriteOnly:
        case PermissionGroupCalendarFullAccess:
            return [EventPermissionStrategy new];
        case PermissionGroupCamera:
            return [AudioVideoPermissionStrategy new];
        case PermissionGroupContacts:
            return [ContactPermissionStrategy new];
        case PermissionGroupLocation:
        case PermissionGroupLocationAlways:
        case PermissionGroupLocationWhenInUse:
            // Local override: never compile/link CoreLocation via permission_handler_apple
            // to avoid App Store ITMS-90683 (NSLocationAlwaysAndWhenInUseUsageDescription).
            // See https://github.com/Baseflow/flutter-permission-handler/issues/1543
            return [UnknownPermissionStrategy new];
        case PermissionGroupMediaLibrary:
            return [MediaLibraryPermissionStrategy new];
        case PermissionGroupMicrophone:
            return [AudioVideoPermissionStrategy new];
        case PermissionGroupPhone:
            return [PhonePermissionStrategy new];
        case PermissionGroupPhotos:
            #if PERMISSION_PHOTOS
            return [[PhotoPermissionStrategy alloc] initWithAccessAddOnly:false];
            #else
            return [PhotoPermissionStrategy new];
            #endif
        case PermissionGroupPhotosAddOnly:
            #if PERMISSION_PHOTOS
            return [[PhotoPermissionStrategy alloc] initWithAccessAddOnly:true];
            #else
            return [PhotoPermissionStrategy new];
            #endif
        case PermissionGroupReminders:
            return [EventPermissionStrategy new];
        case PermissionGroupSensors:
            return [SensorPermissionStrategy new];
        case PermissionGroupSpeech:
            return [SpeechPermissionStrategy new];
        case PermissionGroupNotification:
            return [NotificationPermissionStrategy new];
        case PermissionGroupStorage:
            return [StoragePermissionStrategy new];
        case PermissionGroupBluetooth:
            return [BluetoothPermissionStrategy new];
        case PermissionGroupAppTrackingTransparency:
            return [AppTrackingTransparencyPermissionStrategy new];
        case PermissionGroupCriticalAlerts:
            return [CriticalAlertsPermissionStrategy new];
        case PermissionGroupAssistant:
            return [AssistantPermissionStrategy new];
        case PermissionGroupBackgroundRefresh:
            return [BackgroundRefreshStrategy new];
        default:
            return [UnknownPermissionStrategy new];
    }
}

@end
