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
    var latestLink:String?
    var eventSink:FlutterEventSink?
    // Links that arrived while Dart was not listening (cold launch, engine
    // still starting, HelloPage not mounted yet). Handed out by
    // getInitialLink first, the rest flushed when the event stream opens.
    private var pendingLinks: [String] = []
    private var connectionLink: String?
    static let kMessagesChannel = "deep_links/messages";
    static let kEventsChannel = "deep_links/events";
    static let shared = DeepLinkPlugin()
    
    static func register(with registrar: FlutterPluginRegistrar) {
        FlutterMethodChannel(name: kMessagesChannel, binaryMessenger: registrar.messenger()).setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "getInitialLink":
                let shared = DeepLinkPlugin.shared
                result(shared.pendingLinks.isEmpty ? nil : shared.pendingLinks.removeFirst())
            case "getLatestLink":
                result(DeepLinkPlugin.shared.latestLink)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        let eventChannel = FlutterEventChannel(name: kEventsChannel, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(DeepLinkPlugin.shared)
        registrar.addApplicationDelegate(DeepLinkPlugin.shared)
        registrar.addSceneDelegate(DeepLinkPlugin.shared)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL
        return deliver(url?.absoluteString)
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return deliver(url.absoluteString)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        return handle(userActivity: userActivity)
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        guard let connectionOptions = connectionOptions else { return false }
        return handle(connectionOptions: connectionOptions)
    }
    
    /// Also called directly from SceneDelegate, since the plugin may be
    /// registered after the scene has already connected on cold launch.
    @discardableResult
    func handle(connectionOptions: UIScene.ConnectionOptions) -> Bool {
        var link = connectionOptions.urlContexts.first?.url.absoluteString
        if link == nil, let activity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }) {
            link = activity.webpageURL?.absoluteString
        }
        guard let link = link else { return false }
        if link == connectionLink { return true } // already delivered via the other path
        connectionLink = link
        return deliver(link)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        return deliver(URLContexts.first?.url.absoluteString)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Bool {
        return handle(userActivity: userActivity)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        let pending = pendingLinks
        pendingLinks = []
        if !pending.isEmpty {
            DispatchQueue.main.async { pending.forEach { events($0) } }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    private func handle(userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }
        return deliver(userActivity.webpageURL?.absoluteString)
    }
    
    @discardableResult
    private func deliver(_ link: String?) -> Bool {
        guard let link = link else {
            return false
        }
        latestLink = link
        if let eventSink = eventSink {
            eventSink(link)
        } else {
            pendingLinks.append(link)
        }
        return true
    }
}
