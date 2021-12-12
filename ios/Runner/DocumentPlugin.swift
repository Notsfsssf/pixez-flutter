//
//  DocumentPlugin.swift
//  Runner
//
//  Created by perol on 2021/12/12.
//

import Foundation
import Flutter

struct DocumentPlugin {
    static func bind(controller : FlutterViewController){
        let channel = FlutterMethodChannel(name: "com.perol.dev/save",
                                                  binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "save" else {
                result(FlutterMethodNotImplemented)
                return
            }
            let args = call.arguments as? [String:Any]
            
            
            let data  = args?["data"] as! FlutterStandardTypedData
            let name = args?["name"] as! String
            let sData = Data(data.data)
            save(data: sData, name: name)
        })
    }
    
    static func save(data:Data,name:String){
        
    }
}
