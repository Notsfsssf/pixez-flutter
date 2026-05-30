// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview-3.23.8"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.1"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.2"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "share_plus", path: "../.packages/share_plus-13.1.0"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-10.1.0"),
        .package(name: "in_app_purchase_storekit", path: "../.packages/in_app_purchase_storekit-0.4.8"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13+6"),
        .package(name: "just_audio", path: "../.packages/just_audio-0.10.5"),
        .package(name: "audio_session", path: "../.packages/audio_session-0.2.2"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.9.3"),
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus-1.6.1"),
        .package(name: "file_picker", path: "../.packages/file_picker-12.0.0-beta.5"),
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-13.1.0"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "in-app-purchase-storekit", package: "in_app_purchase_storekit"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "just-audio", package: "just_audio"),
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
