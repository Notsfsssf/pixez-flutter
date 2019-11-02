//
//  DeepLinkPlugin.swift
//  Runner
//
//  Created by Perol Notsf on 2023/10/5.
//

import Foundation
import Flutter
import UIKit

class DeepLinkPlugin : NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
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
        registrar.addSceneDelegate(DeepLinkPlugin.shared)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL
        setLatestLink(url?.absoluteString, setInitialIfNeeded: true)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return setLatestLink(url.absoluteString)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        return handle(userActivity: userActivity)
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        if let url = connectionOptions?.urlContexts.first?.url {
            return setLatestLink(url.absoluteString, setInitialIfNeeded: true)
        }
        if let userActivity = connectionOptions?.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }) {
            return handle(userActivity: userActivity, setInitialIfNeeded: true)
        }
        return false
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        guard let url = URLContexts.first?.url else {
            return false
        }
        return setLatestLink(url.absoluteString)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Bool {
        return handle(userActivity: userActivity)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    private func handle(userActivity: NSUserActivity, setInitialIfNeeded: Bool = false) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }
        return setLatestLink(
            userActivity.webpageURL?.absoluteString,
            setInitialIfNeeded: setInitialIfNeeded || eventSink == nil
        )
    }
    
    @discardableResult
    private func setLatestLink(_ link: String?, setInitialIfNeeded: Bool = false) -> Bool {
        guard let link = link else {
            return false
        }
        latestLink = link
        if setInitialIfNeeded, initialLink == nil {
            initialLink = link
        }
        eventSink?(link)
        return true
    }
}
