//
//  CriticalAlertsPermissionStrategy.h
//  permission_handler
//
//  Created by Neal Soni on 2021/6/8.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_CRITICAL_ALERTS

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface CriticalAlertsPermissionStrategy : NSObject <PermissionStrategy>

@end

#else

#import "UnknownPermissionStrategy.h"
@interface CriticalAlertsPermissionStrategy : UnknownPermissionStrategy
@end

#endif
