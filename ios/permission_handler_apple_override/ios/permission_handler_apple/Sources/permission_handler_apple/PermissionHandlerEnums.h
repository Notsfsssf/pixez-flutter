//
//  PermissionHandlerEnums.h
//  permission_handler
//
//  Created by Razvan Lung on 15/02/2019.
//

// ios: [PermissionGroupCalendar, PermissionGroupCalendarWriteOnly]
// Info.plist: [NSCalendarsUsageDescription, NSCalendarWriteOnlyAccessUsageDescription]
// dart: PermissionGroup.calendar
#ifndef PERMISSION_EVENTS
    #define PERMISSION_EVENTS 0
#endif

// ios: PermissionGroupReminders
// Info.plist: NSRemindersFullAccessUsageDescription
// dart: PermissionGroup.reminders
#ifndef PERMISSION_REMINDERS
    #define PERMISSION_REMINDERS 0
#endif

// ios: PermissionGroupContacts
// Info.plist: NSContactsUsageDescription
// dart: PermissionGroup.contacts
#ifndef PERMISSION_CONTACTS
    #define PERMISSION_CONTACTS 0
#endif

// ios: PermissionGroupCamera
// Info.plist: NSCameraUsageDescription
// dart: PermissionGroup.camera
#ifndef PERMISSION_CAMERA
    #define PERMISSION_CAMERA 0
#endif

// ios: PermissionGroupMicrophone
// Info.plist: NSMicrophoneUsageDescription
// dart: PermissionGroup.microphone
#ifndef PERMISSION_MICROPHONE
    #define PERMISSION_MICROPHONE 0
#endif

// ios: PermissionGroupSpeech
// Info.plist: NSSpeechRecognitionUsageDescription
// dart: PermissionGroup.speech
#ifndef PERMISSION_SPEECH_RECOGNIZER
    #define PERMISSION_SPEECH_RECOGNIZER 0
#endif

// ios: PermissionGroupPhotos
// Info.plist: NSPhotoLibraryUsageDescription
// dart: PermissionGroup.photos
#ifndef PERMISSION_PHOTOS
    #define PERMISSION_PHOTOS 0
#endif

// ios: PermissionGroupPhotosAddOnly
// Info.plist: NSPhotoLibraryAddUsageDescription
// dart: PermissionGroup.photosAddOnly
#ifndef PERMISSION_PHOTOS_ADD_ONLY
    #define PERMISSION_PHOTOS_ADD_ONLY 0
#endif

// ios: [PermissionGroupLocation, PermissionGroupLocationAlways, PermissionGroupLocationWhenInUse]
// Info.plist: [NSLocationUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription, NSLocationWhenInUseUsageDescription]
// dart: [PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse]
#ifndef PERMISSION_LOCATION
    #define PERMISSION_LOCATION 0
#endif

// ios: PermissionGroupNotification
// dart: PermissionGroup.notification
#ifndef PERMISSION_NOTIFICATIONS
    #define PERMISSION_NOTIFICATIONS 0
#endif

// ios: PermissionGroupMediaLibrary
// Info.plist: [NSAppleMusicUsageDescription, kTCCServiceMediaLibrary]
// dart: PermissionGroup.mediaLibrary
#ifndef PERMISSION_MEDIA_LIBRARY
    #define PERMISSION_MEDIA_LIBRARY 0
#endif

// ios: PermissionGroupSensors
// Info.plist: NSMotionUsageDescription
// dart: PermissionGroup.sensors
#ifndef PERMISSION_SENSORS
    #define PERMISSION_SENSORS 0
#endif

// ios: PermissionGroupBluetooth
// Info.plist: [NSBluetoothAlwaysUsageDescription, NSBluetoothPeripheralUsageDescription]
// dart: PermissionGroup.bluetooth
#ifndef PERMISSION_BLUETOOTH
    #define PERMISSION_BLUETOOTH 0
#endif

// ios: PermissionGroupAppTrackingTransparency
// Info.plist: [NSUserTrackingUsageDescription]
// dart: PermissionGroup.appTrackingTransparency
#ifndef PERMISSION_APP_TRACKING_TRANSPARENCY
    #define PERMISSION_APP_TRACKING_TRANSPARENCY 0
#endif

// ios: PermissionGroupCriticalAlerts
// Info.plist: UNAuthorizationOptionCriticalAlert
// dart: PermissionGroup.criticalAlerts
#ifndef PERMISSION_CRITICAL_ALERTS
    #define PERMISSION_CRITICAL_ALERTS 0
#endif

// ios: PermissionGroupAssistant
// Info.plist: [NSSiriUsageDescription]
// dart: PermissionGroup.assistant
#ifndef PERMISSION_ASSISTANT
    #define PERMISSION_ASSISTANT 0
#endif

// ios: PermissionGroupCalendarFullAccess
// Info.plist: [NSCalendarsFullAccessUsageDescription]
// dart: PermissionGroup.calendarFullAccess
#ifndef PERMISSION_EVENTS_FULL_ACCESS
    #define PERMISSION_EVENTS_FULL_ACCESS 0
#endif

typedef NS_ENUM(int, PermissionGroup) {
    PermissionGroupCalendar = 0,
    PermissionGroupCamera,
    PermissionGroupContacts,
    PermissionGroupLocation,
    PermissionGroupLocationAlways,
    PermissionGroupLocationWhenInUse,
    PermissionGroupMediaLibrary,
    PermissionGroupMicrophone,
    PermissionGroupPhone,
    PermissionGroupPhotos,
    PermissionGroupPhotosAddOnly,
    PermissionGroupReminders,
    PermissionGroupSensors,
    PermissionGroupSms,
    PermissionGroupSpeech,
    PermissionGroupStorage,
    PermissionGroupIgnoreBatteryOptimizations,
    PermissionGroupNotification,
    PermissionGroupAccessMediaLocation,
    PermissionGroupActivityRecognition,
    PermissionGroupUnknown,
    PermissionGroupBluetooth,
    PermissionGroupManageExternalStorage,
    PermissionGroupSystemAlertWindow,
    PermissionGroupRequestInstallPackages,
    PermissionGroupAppTrackingTransparency,
    PermissionGroupCriticalAlerts,
    PermissionGroupAccessNotificationPolicy,
    PermissionGroupBluetoothScan,
    PermissionGroupBluetoothAdvertise,
    PermissionGroupBluetoothConnect,
    PermissionGroupNearbyWifiDevices,
    PermissiongroupVideos,
    PermissionGroupAudio,
    PermissionGroupScheduleExactAlarm,
    PermissionGroupSensorsAlways,
    PermissionGroupCalendarWriteOnly,
    PermissionGroupCalendarFullAccess,
    PermissionGroupAssistant,
    PermissionGroupBackgroundRefresh
};

typedef NS_ENUM(int, PermissionStatus) {
    PermissionStatusDenied = 0,
    PermissionStatusGranted = 1,
    PermissionStatusRestricted = 2,
    PermissionStatusLimited = 3,
    PermissionStatusPermanentlyDenied = 4,
    PermissionStatusProvisional = 5,
};

typedef NS_ENUM(int, ServiceStatus) {
    ServiceStatusDisabled = 0,
    ServiceStatusEnabled,
    ServiceStatusNotApplicable,
};
