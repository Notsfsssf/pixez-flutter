#import <Flutter/Flutter.h>
#import "PermissionManager.h"

@interface PermissionHandlerPlugin : NSObject<FlutterPlugin>
- (instancetype)initWithPermissionManager:(PermissionManager *)permissionManager;
@end
