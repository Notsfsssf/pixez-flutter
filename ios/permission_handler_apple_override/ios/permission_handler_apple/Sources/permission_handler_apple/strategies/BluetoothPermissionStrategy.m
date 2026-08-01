//
//  BluetoothPermissionStrategy.m
//  permission_handler
//
//  Created by Rene Floor on 12/03/2021.
//

#import "BluetoothPermissionStrategy.h"

#if PERMISSION_BLUETOOTH

@implementation BluetoothPermissionStrategy {
    CBCentralManager *_centralManager;
    PermissionGroup _requestedPermission;
    PermissionStatusHandler _permissionStatusHandler;
    ServiceStatusHandler _serviceStatusHandler;
}

- (void)initManagerIfNeeded {
    if (_centralManager == nil) {
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey: @NO};
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    }
}

/// Reads the permission status of the Bluetooth service.
///
/// The behavior differs across iOS versions:
/// - Starting with iOS 13.1, this function returns the expected result.
/// - On iOS 13.0, applications are unable to check for the permission status without triggering a
/// permission request. Therefore, `PermissionStatusDenied` is always returned. To obtain the
/// actual permission status, the application should request permission using `requestPermission()`.
/// If the permission was already granted, no dialog will pop up.
/// - Below iOS 13.0, applications do not have to ask for permission to use Bluetooth. Therefore,
/// `PermissionStatusGranted` is always returned.
- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    if (@available(iOS 13.1, *)) {
        CBManagerAuthorization blePermission = [CBCentralManager authorization];
        
        return [BluetoothPermissionStrategy parsePermission:blePermission];
    } else if (@available(iOS 13.0, *)) {
        return PermissionStatusDenied;
    }
    return PermissionStatusGranted;
}

/// Asynchronously requests the status of the Bluetooth service.
///
/// The result will be fetched in `handleCheckServiceStatusCallback`, which will in turn call
/// `completionHandler` with either `ServiceStatusEnabled` or `ServiceStatusDisabled`.
///
/// If the Bluetooth permission has been requested and was denied, this will return `ServiceStatusDisabled`,
/// regardless of the actual state of the Bluetooth service.
/// If the Bluetooth permission has not been granted or denied yet, this call will trigger a permission dialog, asking
/// the user to give the application access to Bluetooth.
- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
    [self initManagerIfNeeded];
    
    _serviceStatusHandler = completionHandler;
    _requestedPermission = permission;
}

- (void)handleCheckServiceStatusCallback:(CBCentralManager *)centralManager {
    ServiceStatus serviceStatus = [centralManager state] == CBManagerStatePoweredOn ? ServiceStatusEnabled : ServiceStatusDisabled;
    _serviceStatusHandler(serviceStatus);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler {
    [self initManagerIfNeeded];
    PermissionStatus status = [self checkPermissionStatus:permission];
    
    if (status != PermissionStatusDenied) {
        completionHandler(status);
        return;
    }
    
    _permissionStatusHandler = completionHandler;
    _requestedPermission = permission;
}

- (void)handleRequestPermissionCallback:(CBCentralManager *)centralManager {
    if (@available(iOS 13.0, *)) {
        CBManagerAuthorization blePermission = [centralManager authorization];
        PermissionStatus permissionStatus = [BluetoothPermissionStrategy parsePermission:blePermission];
        _permissionStatusHandler(permissionStatus);
    } else {
        _permissionStatusHandler(PermissionStatusGranted);
    }
}

+ (PermissionStatus)parsePermission:(CBManagerAuthorization)bluetoothPermission API_AVAILABLE(ios(13)) {
    switch(bluetoothPermission){
        case CBManagerAuthorizationNotDetermined:
            return PermissionStatusDenied;
        case CBManagerAuthorizationRestricted:
            return PermissionStatusRestricted;
        case CBManagerAuthorizationDenied:
            return PermissionStatusPermanentlyDenied;
        case CBManagerAuthorizationAllowedAlways:
            return PermissionStatusGranted;
    }
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)centralManager {
    if (_permissionStatusHandler != nil) {
        [self handleRequestPermissionCallback:centralManager];
    }
    
    if (_serviceStatusHandler != nil) {
        [self handleCheckServiceStatusCallback:centralManager];
    }
}

@end

#else

@implementation BluetoothPermissionStrategy
@end

#endif
