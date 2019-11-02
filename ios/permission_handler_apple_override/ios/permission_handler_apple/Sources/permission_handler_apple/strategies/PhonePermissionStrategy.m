//
//  PhonePermissionStrategy.m
//  permission_handler
//
//  Created by Sebastian Roth on 5/20/19.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "PhonePermissionStrategy.h"

@implementation PhonePermissionStrategy

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
  return PermissionStatusDenied;
}

- (void)checkServiceStatus:(PermissionGroup)permission completionHandler:(ServiceStatusHandler)completionHandler {
  UIApplication *app = [UIApplication sharedApplication];
  NSURL *telURL = [NSURL URLWithString:@"tel://"];
  if (![app canOpenURL:telURL]) {
      completionHandler(ServiceStatusNotApplicable);
  }
  completionHandler([self canDevicePlaceAPhoneCall] ? ServiceStatusEnabled : ServiceStatusDisabled);
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler errorHandler:(PermissionErrorHandler)errorHandler {
  completionHandler(PermissionStatusPermanentlyDenied);
}


/**
 * Returns YES if the device can place a phone call.
 */
-(bool) canDevicePlaceAPhoneCall {
  CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if(@available(iOS 12.0, *)) {
    NSDictionary<NSString *, CTCarrier *> *providers = [netInfo serviceSubscriberCellularProviders];
    for (NSString *key in providers) {
      CTCarrier *carrier = [providers objectForKey:key];
      if ([self canPlacePhoneCallWithCarrier:carrier]) {
        return YES;
      }
    }
    
    return NO;
  } else {
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return [self canPlacePhoneCallWithCarrier:carrier];
  }
}

-(bool)canPlacePhoneCallWithCarrier:(CTCarrier *)carrier {
  NSString *networkCode = [carrier mobileNetworkCode];
  if (networkCode.length == 0 || [networkCode isEqualToString:@"65535"]) {
    // Device is unable to initiate a call at this time. SIM might be missing.
    return NO;
  }

  // Mobile Network Code is valid and device can initiate a call
  return YES;
}

@end
