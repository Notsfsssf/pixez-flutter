//
//  NotificationPermissionStrategy.h
//  permission_handler
//
//  Created by Tong on 2019/10/21.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_NOTIFICATIONS

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface NotificationPermissionStrategy : NSObject <PermissionStrategy>

@end

#else

#import "UnknownPermissionStrategy.h"
@interface NotificationPermissionStrategy : UnknownPermissionStrategy
@end

#endif
