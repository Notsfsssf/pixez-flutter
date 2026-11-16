import Cocoa
import FlutterMacOS

/// Desktop downloads go to ordinary files. Report success only after the write.
struct DocumentPlugin {
    private static func folderKey(_ mode: Int) -> String { "pixez.downloadFolder.\(mode)" }

    private static func withFolder<T>(_ mode: Int, _ action: (URL) throws -> T) throws -> T {
        var stale = false
        let folder: URL
        if let bookmark = UserDefaults.standard.data(forKey: folderKey(mode)) {
            folder = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope,
                             relativeTo: nil, bookmarkDataIsStale: &stale)
        } else {
            folder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("PixEz", isDirectory: true)
        }
        let scoped = folder.startAccessingSecurityScopedResource()
        defer { if scoped { folder.stopAccessingSecurityScopedResource() } }
        if stale {
            let refreshed = try folder.bookmarkData(options: .withSecurityScope,
                                                   includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(refreshed, forKey: folderKey(mode))
        }
        return try action(folder)
    }

    private static func target(_ name: String, in folder: URL) throws -> URL {
        guard !name.isEmpty, !name.hasPrefix("/"), !name.split(separator: "/").contains("..") else {
            throw NSError(domain: "PixEz", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid download filename"])
        }
        return folder.appendingPathComponent(name)
    }

    static func bind(controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "com.perol.dev/save",
                                           binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler { call, result in
            let args = call.arguments as? [String: Any] ?? [:]
            let mode = args["save_mode"] as? Int ?? 0
            do {
                switch call.method {
                case "get_path":
                    result(try withFolder(mode) { $0.resolvingSymlinksInPath().path })
                case "exist":
                    result(try withFolder(mode) {
                        FileManager.default.fileExists(atPath: try target(args["name"] as? String ?? "", in: $0).path)
                    })
                case "save", "saveFromPath":
                    let data: Data
                    if call.method == "saveFromPath", let source = args["source_path"] as? String {
                        data = try Data(contentsOf: URL(fileURLWithPath: source))
                    } else if let bytes = args["data"] as? FlutterStandardTypedData {
                        data = bytes.data
                    } else {
                        throw NSError(domain: "PixEz", code: 2,
                                      userInfo: [NSLocalizedDescriptionKey: "Missing download data"])
                    }
                    try withFolder(mode) { folder in
                        let file = try target(args["name"] as? String ?? "", in: folder)
                        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(),
                                                                withIntermediateDirectories: true)
                        try data.write(to: file, options: .atomic)
                    }
                    result(true)
                case "choice_folder":
                    let panel = NSOpenPanel()
                    panel.directoryURL = try? withFolder(mode) { $0 }
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    panel.canCreateDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.begin { response in
                        guard response == .OK, let url = panel.url else { result(nil); return }
                        let scoped = url.startAccessingSecurityScopedResource()
                        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                        do {
                            let bookmark = try url.bookmarkData(options: .withSecurityScope,
                                                               includingResourceValuesForKeys: nil, relativeTo: nil)
                            UserDefaults.standard.set(bookmark, forKey: folderKey(mode))
                            result(url.path)
                        } catch {
                            result(FlutterError(code: "SAVE_FOLDER", message: error.localizedDescription, details: nil))
                        }
                    }
                case "openSave":
                    let panel = NSSavePanel()
                    panel.nameFieldStringValue = args["name"] as? String ?? "image.jpg"
                    panel.begin { response in
                        guard response == .OK, let url = panel.url else { result(false); return }
                        do {
                            guard let bytes = args["data"] as? FlutterStandardTypedData else { result(false); return }
                            try bytes.data.write(to: url, options: .atomic)
                            result(true)
                        } catch {
                            result(FlutterError(code: "SAVE_FAILED", message: error.localizedDescription, details: nil))
                        }
                    }
                case "permissionStatus", "requestPermission":
                    result(true)
                default:
                    result(FlutterMethodNotImplemented)
                }
            } catch {
                result(FlutterError(code: "SAVE_FAILED", message: error.localizedDescription, details: nil))
            }
        }
    }
}
