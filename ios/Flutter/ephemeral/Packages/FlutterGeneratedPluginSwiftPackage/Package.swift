// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
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
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation"),
        .package(name: "share_plus", path: "../.packages/share_plus"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus"),
        .package(name: "in_app_purchase_storekit", path: "../.packages/in_app_purchase_storekit"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios"),
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview"),
        .package(name: "just_audio", path: "../.packages/just_audio"),
        .package(name: "audio_session", path: "../.packages/audio_session"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation"),
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus"),
        .package(name: "file_picker", path: "../.packages/file_picker"),
        .package(name: "device_info_plus", path: "../.packages/device_info_plus")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "in-app-purchase-storekit", package: "in_app_purchase_storekit"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "just-audio", package: "just_audio"),
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "device-info-plus", package: "device_info_plus")
            ]
        )
    ]
)
