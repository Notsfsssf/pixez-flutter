import Cocoa
import FlutterMacOS
import IOKit.ps
import Photos

class MainFlutterWindow: NSWindow, FlutterStreamHandler {
    func saveImageToPhotosLibrary(imageData: Data) {
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            let placeholder = creationRequest.placeholderForCreatedAsset
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject!)
            albumChangeRequest?.addAssets([placeholder!] as NSFastEnumeration)
        } completionHandler: { success, error in
            if success {
                print("Image saved to Photos library")
            } else {
                print("Error saving image to Photos library:", error?.localizedDescription ?? "")
            }
        }
    }
    
    func saveImageToPhotosLibrary1(imageData: Data) {
        if let image = NSImage(data: imageData) {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if let error = error {
                        print("Error saving image to Photos library: \(error.localizedDescription)")
                    } else {
                        print("Image saved to Photos library successfully!")
                    }
                }
            } else {
                print("Failed to create image from data.")
            }
    }
    
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        let batteryChannel = FlutterMethodChannel(
            name: "com.perol.dev/custom_tab",
            binaryMessenger: flutterViewController.engine.binaryMessenger)
        batteryChannel.setMethodCallHandler { call, _ in
            if call.method == "getInitialLink" {}
        }

        let uniLinksChannel = FlutterMethodChannel(
            name: "uni_links/messages",
            binaryMessenger: flutterViewController.engine.binaryMessenger)
        uniLinksChannel.setMethodCallHandler { call, result in
            if call.method == "getInitialLink" {
                result(nil)
            }
        }
        let eventChannel = FlutterEventChannel(name: "deep_links/events", binaryMessenger: flutterViewController.engine.binaryMessenger)
        eventChannel.setStreamHandler(self)

        DocumentPlugin.bind(controller: flutterViewController)

        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.eventSink = nil
        return nil
    }
}
