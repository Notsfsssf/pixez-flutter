//
//  DeepLinkPlugin.swift
//  Runner
//
//  Created by Perol Notsf on 2023/10/5.
//

import Foundation
import Flutter

class DeepLinkPlugin : NSObject, FlutterPlugin, FlutterStreamHandler {
    var initialLink:String?
    var latestLink:String?
    var eventSink:FlutterEventSink?
    static let kMessagesChannel = "deep_links/messages";
    static let kEventsChannel = "deep_links/events";
    static let shared = DeepLinkPlugin()
    
    static func register(with registrar: FlutterPluginRegistrar) {
        FlutterMethodChannel(name: kMessagesChannel, binaryMessenger: registrar.messenger()).setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "getInitialLink" {
                result(DeepLinkPlugin.shared.initialLink)
            }
        })
        let eventChannel = FlutterEventChannel(name: kEventsChannel, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(DeepLinkPlugin.shared)
        registrar.addApplicationDelegate(DeepLinkPlugin.shared)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL
        initialLink = url?.absoluteString
        latestLink = initialLink
        eventSink?(latestLink)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        latestLink = url.absoluteString
        eventSink?(latestLink)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            self.latestLink = userActivity.webpageURL?.absoluteString
            eventSink?(latestLink)
            if eventSink == nil {
                self.initialLink = self.latestLink
            }
            return true
        }
        return false
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
