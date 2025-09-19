import Cocoa
import SwiftUI

class TestApp: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("TestApp launched")
        
        let frame = NSMakeRect(100, 100, 400, 300)
        window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window?.title = "Test Window"
        window?.makeKeyAndOrderFront(nil)
        window?.contentViewController = NSHostingController(
            rootView: Text("Hello, World!").frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        
        print("Test window created and shown")
    }
}