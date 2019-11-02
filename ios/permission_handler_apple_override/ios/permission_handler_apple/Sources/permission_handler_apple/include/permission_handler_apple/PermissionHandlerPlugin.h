#import <Flutter/Flutter.h>

@class PermissionManager;

@interface PermissionHandlerPlugin : NSObject<FlutterPlugin>
- (instancetype)initWithPermissionManager:(PermissionManager *)permissionManager;
@end
