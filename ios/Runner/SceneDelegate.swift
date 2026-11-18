//
//  SceneDelegate.swift
//  Runner
//
//  Created by Perol Notsf on 2026/6/2.
//

import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        // Capture widget / universal-link launch URLs even if DeepLinkPlugin
        // registers after the scene connects (cold launch).
        DeepLinkPlugin.shared.handle(connectionOptions: connectionOptions)
    }

    @available(iOS 26.0, *)
    override func preferredWindowingControlStyle(for windowScene: UIWindowScene) -> UIWindowScene.WindowingControlStyle {
        return .minimal
    }
}
