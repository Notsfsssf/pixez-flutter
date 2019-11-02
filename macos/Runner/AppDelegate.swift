import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    var eventSink: FlutterEventSink?
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func application(_ application: NSApplication, open urls: [URL]) {
        print(urls)
        for i in urls {
            eventSink?(i.absoluteString)
        }
    }
}
