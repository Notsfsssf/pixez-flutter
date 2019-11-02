#import "PermissionHandlerPlugin.h"


@implementation PermissionHandlerPlugin {
    PermissionManager *_Nonnull _permissionManager;
    _Nullable FlutterResult _methodResult;
}

- (instancetype)initWithPermissionManager:(PermissionManager *)permissionManager {
    self = [super init];
    if (self) {
        _permissionManager = permissionManager;
    }
    
    return self;
}

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter.baseflow.com/permissions/methods"
                                     binaryMessenger:[registrar messenger]];
    PermissionManager *permissionManager = [[PermissionManager alloc] initWithStrategyInstances];
    PermissionHandlerPlugin *instance = [[PermissionHandlerPlugin alloc] initWithPermissionManager:permissionManager];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"checkPermissionStatus" isEqualToString:call.method]) {
        PermissionGroup permission = [Codec decodePermissionGroupFrom:call.arguments];
        [PermissionManager checkPermissionStatus:permission result:result];
    } else if ([@"checkServiceStatus" isEqualToString:call.method]) {
        PermissionGroup permission = [Codec decodePermissionGroupFrom:call.arguments];
        [PermissionManager checkServiceStatus:permission result:result];
    } else if ([@"requestPermissions" isEqualToString:call.method]) {
        if (_methodResult != nil) {
            result([FlutterError errorWithCode:@"ERROR_ALREADY_REQUESTING_PERMISSIONS" message:@"A request for permissions is already running, please wait for it to finish before doing another request (note that you can request multiple permissions at the same time)." details:nil]);
            return;
        }
        
        _methodResult = result;
        NSArray *permissions = [Codec decodePermissionGroupsFrom:call.arguments];
        
        [_permissionManager
         requestPermissions:permissions completion:^(NSDictionary *permissionRequestResults) {
             if (self->_methodResult != nil) {
                 self->_methodResult(permissionRequestResults);
             }
             
             self->_methodResult = nil;
        } errorHandler:^(NSString *errorCode, NSString *errorDescription) {
            self->_methodResult([FlutterError errorWithCode:errorCode message:errorDescription details:nil]);
            self->_methodResult = nil;
        }
];
        
    } else if ([@"shouldShowRequestPermissionRationale" isEqualToString:call.method]) {
        result(@false);
    } else if ([@"openAppSettings" isEqualToString:call.method]) {
        [PermissionManager openAppSettings:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
