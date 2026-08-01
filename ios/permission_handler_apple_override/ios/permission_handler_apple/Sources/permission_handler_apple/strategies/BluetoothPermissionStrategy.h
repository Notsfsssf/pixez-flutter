//
//  BluetoothPermissionStrategy.h
//  permission_handler
//
//  Created by Rene Floor on 12/03/2021.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_BLUETOOTH

#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothPermissionStrategy : NSObject <PermissionStrategy, CBCentralManagerDelegate>
- (void)initManagerIfNeeded;
@end

#else

#import "UnknownPermissionStrategy.h"

@interface BluetoothPermissionStrategy : UnknownPermissionStrategy
@end

#endif
