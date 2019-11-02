//
//  AppTrackingTransparency.h
//  permission_handler
//
//  Created by Jan-Derk on 21/05/2021.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_APP_TRACKING_TRANSPARENCY

#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface AppTrackingTransparencyPermissionStrategy : NSObject <PermissionStrategy>
@end

#else

#import "UnknownPermissionStrategy.h"

@interface AppTrackingTransparencyPermissionStrategy : UnknownPermissionStrategy
@end

#endif
