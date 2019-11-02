//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"

#if PERMISSION_CONTACTS

#import <AddressBook/ABAddressBook.h>
#import <Contacts/Contacts.h>

@interface ContactPermissionStrategy : NSObject <PermissionStrategy>
@end

#else

#import "UnknownPermissionStrategy.h"
@interface ContactPermissionStrategy : UnknownPermissionStrategy
@end

#endif
