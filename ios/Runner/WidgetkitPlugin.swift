//
//  WidgetkitPlugin.swift
//  Runner
//
//  Created by  perol on 2021/3/28.
//

import Foundation

public class WidgetkitPlugin {
  public  static func bind(controller : FlutterViewController){
        let batteryChannel = FlutterMethodChannel(name: "com.perol.dev/widgetkit",
                                                  binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "notify"  {
                notify()
                result(nil)
                return
            }
            
        })
    }
    
    private static func notify()  {
        AppWidgetDBManager.copyDb()
    }
}
