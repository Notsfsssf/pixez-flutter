import Cocoa
import FlutterMacOS
import ImageIO

/// Turns an unzipped ugoira into a GIF, on the same channel and method the
/// iOS and Android runners use. Returns the temporary GIF path.
struct UgoiraPlugin {
    struct Failure: LocalizedError {
        let errorDescription: String?
    }

    static func bind(controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
                                           binaryMessenger: controller.engine.binaryMessenger)
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
                    let path = try encode(folder: folder, delays: delays, fallbackDelay: fallbackDelay)
                    DispatchQueue.main.async { result(path) }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "encode_failed", message: error.localizedDescription, details: nil))
                    }
                }
            }
        }
    }

    /// Frames are the zip's numbered files; [delays] are per-frame milliseconds
    /// in the same order, as listed in the ugoira metadata.
    private static func encode(folder: String, delays: [Int], fallbackDelay: Int) throws -> String {
        let names = try FileManager.default.contentsOfDirectory(atPath: folder)
            .filter { !$0.hasPrefix(".") }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        guard !names.isEmpty else { throw Failure(errorDescription: "No ugoira frames found") }
        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("ugoira_\(UUID().uuidString).gif")
        guard let destination = CGImageDestinationCreateWithURL(
            output as CFURL, "com.compuserve.gif" as CFString, names.count, nil)
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
