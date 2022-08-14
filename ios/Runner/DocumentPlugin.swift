//
//  DocumentPlugin.swift
//  Runner
//
//  Created by perol on 2021/12/12.
//

import Foundation
import Flutter
import Photos
import SwiftUI

struct DocumentPlugin {
    static func bind(controller : FlutterViewController){
        let channel = FlutterMethodChannel(name: "com.perol.dev/save",
                                           binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "save"  {
                let args = call.arguments as? [String:Any]
                let data  = args?["data"] as! FlutterStandardTypedData
                let name = args?["name"] as! String
                let sData = Data(data.data)
                save(sData, name: name, in: name.contains("sanity") ? "pxez_sanity" : "pxez")
                result(true)
                return
            } else if call.method == "permissionStatus" {
                if #available(iOS 14, *) {
                    let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                    result(readWriteStatus == .authorized)
                } else {
                    result(true)
                }
                return
            } else if call.method == "requestPermission" {
                if #available(iOS 14, *) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        result(status == .authorized)
                    }
                } else {
                    result(true)
                }
                return
            }
            result(false)
        })
    }
    
    static var picCacheDir: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Pic", isDirectory: true)
    
    static func save(_ data: Data,name : String, in dir: String) {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                    return
                }
                createAlbum(albumName: dir, completion: { assetCollection in
                    self.save(data: data, name: name, assetCollection: assetCollection)
                })
            })
        } else {
            createAlbum(albumName: dir, completion: { assetCollection in
                self.save(data: data, name: name, assetCollection: assetCollection)
            })
        }
    }
    
    static func createAlbum(albumName: String, completion: @escaping (PHAssetCollection) -> Void) {
        if let assetCollection = self.findAlbum(name: albumName) {
            completion(assetCollection)
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }){ success, error in
            if success, let assetCollection = self.findAlbum(name: albumName) {
                completion(assetCollection)
            } else {
                
            }
        }
    }
    
    static func findAlbum(name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        return collection.firstObject
    }
    
    static func save(data:Data,name:String, assetCollection: PHAssetCollection){
        if !FileManager.default.fileExists(atPath: picCacheDir.path) {
            do{
                try FileManager.default.createDirectory(at: picCacheDir, withIntermediateDirectories: true)
            } catch {
                print("create dir failed => \(picCacheDir.path)")
                return
            }
        }
        
        guard let fileName = name.split(separator: " ").last else { return }
        print("fileName = \(fileName)")
        
        let fileUrl = picCacheDir.appendingPathComponent("\(fileName)")
        
        do {
            try data.write(to: fileUrl)
            
        } catch {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            guard let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl) else {
                return
            }
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
            let enumeration: NSArray = assetPlaceHolder == nil ? [] : [assetPlaceHolder!]
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: { (success, error) -> Void in
            print("success \(success)")
            do {
                try FileManager.default.removeItem(at: fileUrl)
            } catch {
            }
        })
    }
}
