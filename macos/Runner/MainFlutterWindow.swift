import Cocoa
import FlutterMacOS
import ImageIO
import UniformTypeIdentifiers
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
        self.setFrame(NSRect(origin: windowFrame.origin, size: NSSize(width: 1280, height: 820)), display: true)
        self.minSize = NSSize(width: 720, height: 560)
        self.title = "PixEz"
        self.center()
        let batteryChannel = FlutterMethodChannel(
            name: "com.perol.dev/custom_tab",
            binaryMessenger: flutterViewController.engine.binaryMessenger)
        batteryChannel.setMethodCallHandler { call, _ in
            if call.method == "getInitialLink" {}
        }

        let uniLinksChannel = FlutterMethodChannel(
            name: "deep_links/messages",
            binaryMessenger: flutterViewController.engine.binaryMessenger)
        uniLinksChannel.setMethodCallHandler { call, result in
            if call.method == "getInitialLink" {
                result(nil)
            }
        }
        let eventChannel = FlutterEventChannel(name: "deep_links/events", binaryMessenger: flutterViewController.engine.binaryMessenger)
        eventChannel.setStreamHandler(self)

        DocumentPlugin.bind(controller: flutterViewController)
        bindUgoiraEncoder(flutterViewController.engine.binaryMessenger)

        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }

    /// Same channel and method the iOS/Android runners use to turn an
    /// unzipped ugoira into a GIF. Returns the temporary GIF path.
    private func bindUgoiraEncoder(_ messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "samples.flutter.dev/battery", binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            guard call.method == "getBatteryLevel",
                  let args = call.arguments as? [String: Any],
                  let folder = args["path"] as? String
            else {
                result(FlutterMethodNotImplemented)
                return
            }
            let fallbackDelay = args["delay"] as? Int ?? 100
            let delays = args["delay_array"] as? [Int] ?? []
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let path = try UgoiraGifEncoder.encode(folder: folder, delays: delays, fallbackDelay: fallbackDelay)
                    DispatchQueue.main.async { result(path) }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "encode_failed", message: error.localizedDescription, details: nil))
                    }
                }
            }
        }
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

enum UgoiraGifEncoder {
    struct Failure: LocalizedError {
        let errorDescription: String?
    }

    /// Frames are the zip's numbered files; [delays] are per-frame milliseconds
    /// in the same order, as listed in the ugoira metadata.
    static func encode(folder: String, delays: [Int], fallbackDelay: Int) throws -> String {
        let names = try FileManager.default.contentsOfDirectory(atPath: folder)
            .filter { !$0.hasPrefix(".") }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        guard !names.isEmpty else { throw Failure(errorDescription: "No ugoira frames found") }
        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("ugoira_\(UUID().uuidString).gif")
        guard let destination = CGImageDestinationCreateWithURL(
            output as CFURL, UTType.gif.identifier as CFString, names.count, nil)
        else { throw Failure(errorDescription: "Unable to create GIF") }
        CGImageDestinationSetProperties(destination, [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0],
        ] as CFDictionary)
        let base = URL(fileURLWithPath: folder)
        var added = 0
        for (index, name) in names.enumerated() {
            guard let source = CGImageSourceCreateWithURL(base.appendingPathComponent(name) as CFURL, nil),
                  let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else { continue }
            let seconds = Double(index < delays.count ? delays[index] : fallbackDelay) / 1000
            CGImageDestinationAddImage(destination, image, [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: seconds,
                    kCGImagePropertyGIFUnclampedDelayTime: seconds,
                ],
            ] as CFDictionary)
            added += 1
        }
        guard added > 0, CGImageDestinationFinalize(destination) else {
            throw Failure(errorDescription: "Unable to write GIF")
        }
        return output.path
    }
}
