//
//  PermissionManager.h
//  permission_handler
//
//  Created by Razvan Lung on 15/02/2019.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AudioVideoPermissionStrategy.h"
#import "AppTrackingTransparencyPermissionStrategy.h"
#import "BackgroundRefreshStrategy.h"
#import "BluetoothPermissionStrategy.h"
#import "ContactPermissionStrategy.h"
#import "EventPermissionStrategy.h"
#import "MediaLibraryPermissionStrategy.h"
#import "PermissionStrategy.h"
#import "PhonePermissionStrategy.h"
#import "PhotoPermissionStrategy.h"
#import "SensorPermissionStrategy.h"
#import "SpeechPermissionStrategy.h"
#import "StoragePermissionStrategy.h"
#import "UnknownPermissionStrategy.h"
#import "NotificationPermissionStrategy.h"
#import "CriticalAlertsPermissionStrategy.h"
#import "AssistantPermissionStrategy.h"
#import "PermissionHandlerEnums.h"
#import "Codec.h"

typedef void (^PermissionRequestCompletion)(NSDictionary *permissionRequestResults);

@interface PermissionManager : NSObject

- (instancetype)initWithStrategyInstances;
- (void)requestPermissions:(NSArray *)permissions completion:(PermissionRequestCompletion)completion errorHandler:(PermissionErrorHandler)errorHandler;

+ (void)checkPermissionStatus:(enum PermissionGroup)permission result:(FlutterResult)result;
+ (void)checkServiceStatus:(enum PermissionGroup)permission result:(FlutterResult)result;
+ (void)openAppSettings:(FlutterResult)result;

@end
