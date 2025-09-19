import Cocoa

class OverlayWindow: NSPanel {
    var isEditorMode: Bool = false {
        didSet {
            ignoresMouseEvents = !isEditorMode
            // Always keep level floating to keep overlays on same level
            level = .floating
            if isEditorMode {
                // When entering editor mode, make the window key
                if oldValue == false {
                    makeKeyAndOrderFront(nil)
                }
            } else {
                makeFirstResponder(nil)
            }
        }
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        isMovable = false
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true // truly click-through by default
        level = .screenSaver // Set back to .screenSaver to force on top of other applications
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
    }

    override var canBecomeKey: Bool { isEditorMode }
    override var canBecomeMain: Bool { isEditorMode }
    
    override func makeKeyAndOrderFront(_ sender: Any?) {
        if isEditorMode {
            level = .floating
        }
        super.makeKeyAndOrderFront(sender)
    }
}