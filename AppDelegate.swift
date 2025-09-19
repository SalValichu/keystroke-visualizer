import Cocoa
import SwiftUI
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    var keystrokeOverlayWindow: OverlayWindow?
    var editorOverlayWindow: OverlayWindow?
    var inputManager: InputManager?
    var layoutManager: LayoutManager?
    var fpsMonitor: FPSMonitor?
    
    // Track visibility and UI state
    private var keystrokeOverlayVisible: Bool = true
    private var editorOverlayVisible: Bool = false
    private var showFPS: Bool = false
    private var editorMode: Bool = false
    private let editorState = EditorState()



    override init() {
        super.init()
        // Remove or comment out this line because handleEditorModeChange is missing
        // editorState.onModeChange = { [weak self] mode in
        //     self?.handleEditorModeChange(mode)
        // }
    }
    
    var statusBarItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Application did finish launching")

        // Input manager
        inputManager = InputManager()
        print("InputManager created")

        // FPS monitor
        fpsMonitor = FPSMonitor()
        fpsMonitor?.start()

        // Overlays
        createKeystrokeOverlayWindow()
        createEditorOverlayWindow()
        print("Overlay windows created")

        // Menu
        setupStatusBarItem()
        print("Status bar item created")

        // Permissions
        checkAccessibilityPermissions()
        print("Accessibility permissions checked")
    }

    func createKeystrokeOverlayWindow() {
        // Calculate overlay size based on default keys layout
        let overlayWidth: CGFloat = 228
        let overlayHeight: CGFloat = 210

        keystrokeOverlayWindow = OverlayWindow(
            contentRect: NSMakeRect(0, 0, overlayWidth, overlayHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        guard let keystrokeOverlayWindow = keystrokeOverlayWindow else { return }
        keystrokeOverlayWindow.isReleasedWhenClosed = false
        keystrokeOverlayWindow.level = .floating // Lower level for better UX
        keystrokeOverlayWindow.isOpaque = false
        keystrokeOverlayWindow.backgroundColor = NSColor.clear
        keystrokeOverlayWindow.ignoresMouseEvents = false
        keystrokeOverlayWindow.hasShadow = false
        keystrokeOverlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        if let _ = inputManager {
            let hostingController = NSHostingController(rootView: KeystrokesOverlayView(inputManager: inputManager!, editorState: editorState))
            keystrokeOverlayWindow.contentViewController = hostingController

            keystrokeOverlayWindow.setFrame(NSMakeRect(0, 0, overlayWidth, overlayHeight), display: true)

            keystrokeOverlayWindow.makeKeyAndOrderFront(nil)
            keystrokeOverlayWindow.orderFrontRegardless()
            print("Keystroke overlay window made key and ordered front")
        }
    }

    func createEditorOverlayWindow() {
        editorOverlayWindow = OverlayWindow(
            contentRect: NSScreen.main?.frame ?? NSMakeRect(0, 0, 1920, 1080),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        guard let editorOverlayWindow = editorOverlayWindow else { return }
        editorOverlayWindow.isReleasedWhenClosed = false
        editorOverlayWindow.level = .floating
        editorOverlayWindow.isOpaque = false
        editorOverlayWindow.backgroundColor = NSColor.clear
        editorOverlayWindow.ignoresMouseEvents = true
        editorOverlayWindow.hasShadow = false
        editorOverlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        if let _ = inputManager {
            let hostingController = NSHostingController(rootView: buildEditorSwiftUIView())
            editorOverlayWindow.contentViewController = hostingController

            if let screen = NSScreen.main {
                editorOverlayWindow.setFrame(screen.frame, display: true)
            }

            // Hide editor overlay initially since editorMode = false
            editorOverlayWindow.orderOut(nil)
            print("Editor overlay window created but hidden")
        }
    }

    private func buildEditorSwiftUIView() -> some View {
        ZStack(alignment: .topLeading) {
            GridOverlay(cell: editorState.gridSize).allowsHitTesting(false)
            if #available(macOS 12.0, *) {
                EditorCanvasView(editor: editorState, input: inputManager!, showBackground: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    private func buildRootSwiftUIView() -> some View {
        ZStack(alignment: .topLeading) {
            // Top-left FPS badge across entire screen
            if showFPS, let fpsMonitor = fpsMonitor {
                Text(String(format: "FPS %.0f", fpsMonitor.fps))
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(6)
            }

            // Editor on top
            if editorMode {
                GridOverlay(cell: editorState.gridSize).allowsHitTesting(false)
                if #available(macOS 12.0, *) {
                    EditorCanvasView(editor: editorState, input: inputManager!, showBackground: true)
                }
            }

            // Bottom-left keystrokes card
            VStack { Spacer()
                HStack { KeystrokesOverlayView(inputManager: inputManager!, editorState: editorState) ; Spacer() }
            }
            .padding(24)


        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Save session without clearing it to preserve user's custom layout
        editorState.saveSession()
        inputManager?.stopEventTap()
        // Remove temporary session folder
        EditorState.removeTemporarySession()
        print("Event tap stopped and temporary session cleaned up")
    }
    
    private func refreshOverlayContent() {
        guard inputManager != nil else { return }
        
        if let keystrokeOverlayWindow = keystrokeOverlayWindow {
            keystrokeOverlayWindow.ignoresMouseEvents = !editorMode
            keystrokeOverlayWindow.isEditorMode = false
            let hostingController = NSHostingController(rootView: KeystrokesOverlayView(inputManager: inputManager!, editorState: editorState))
            keystrokeOverlayWindow.contentViewController = hostingController
            if let screen = NSScreen.main {
                keystrokeOverlayWindow.setFrame(screen.frame, display: false)
            }
            keystrokeOverlayWindow.displayIfNeeded()
        }
        
        if let editorOverlayWindow = editorOverlayWindow {
            editorOverlayWindow.ignoresMouseEvents = !editorMode
            editorOverlayWindow.isEditorMode = editorMode
            let hostingController = NSHostingController(rootView: buildEditorSwiftUIView())
            editorOverlayWindow.contentViewController = hostingController
            if let screen = NSScreen.main {
                editorOverlayWindow.setFrame(screen.frame, display: false)
            }
            editorOverlayWindow.displayIfNeeded()
        }
    }
    
    func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem?.button {
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Keystroke Visualizer")
            } else {
                button.title = "KB"
            }
            button.target = self
            button.action = #selector(statusBarButtonClicked)
        }
        
        let menu = NSMenu()
        let toggleItem = NSMenuItem(title: "Toggle Overlay", action: #selector(statusBarButtonClicked), keyEquivalent: "")
        toggleItem.target = self
        
        let fpsItem = NSMenuItem(title: "Show FPS", action: #selector(toggleFPS), keyEquivalent: "")
        fpsItem.state = showFPS ? .on : .off
        fpsItem.target = self
        
        let editorItem = NSMenuItem(title: "Editor Mode", action: #selector(toggleEditorMode), keyEquivalent: "")
        editorItem.state = editorMode ? .on : .off
        editorItem.target = self

        let presetsMenu = NSMenu(title: "Presets")
        let exportPresetItem = NSMenuItem(title: "Export Preset", action: #selector(exportPreset), keyEquivalent: "")
        exportPresetItem.target = self
        presetsMenu.addItem(exportPresetItem)
        let loadPresetItem = NSMenuItem(title: "Load Preset", action: #selector(loadPreset), keyEquivalent: "")
        loadPresetItem.target = self
        presetsMenu.addItem(loadPresetItem)

        // Add new preset menu items
        let addSpaceBarItem = NSMenuItem(title: "Add Space Bar Preset", action: #selector(addSpaceBarPreset), keyEquivalent: "")
        addSpaceBarItem.target = self
        presetsMenu.addItem(addSpaceBarItem)

        let addWASDItem = NSMenuItem(title: "Add WASD Preset", action: #selector(addWASDPreset), keyEquivalent: "")
        addWASDItem.target = self
        presetsMenu.addItem(addWASDItem)

        let addMouseButtonsItem = NSMenuItem(title: "Add Mouse Buttons Preset", action: #selector(addMouseButtonsPreset), keyEquivalent: "")
        addMouseButtonsItem.target = self
        presetsMenu.addItem(addMouseButtonsItem)

        let presetsItem = NSMenuItem(title: "Presets", action: nil, keyEquivalent: "")
        presetsItem.submenu = presetsMenu

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self

        menu.addItem(toggleItem)
        menu.addItem(fpsItem)
        menu.addItem(editorItem)
        menu.addItem(presetsItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)
        statusBarItem?.menu = menu
        print("Status bar button configured")
    }
    
    @objc func statusBarButtonClicked() {
        print("Status bar button clicked")
        toggleOverlay()
    }
    
    @objc func quitApp() {
        print("Quitting app")
        // Explicitly close and release the overlay windows
        if let keystrokeOverlayWindow = keystrokeOverlayWindow {
            keystrokeOverlayWindow.close()
            self.keystrokeOverlayWindow = nil
        }
        if let editorOverlayWindow = editorOverlayWindow {
            editorOverlayWindow.close()
            self.editorOverlayWindow = nil
        }
        NSApp.terminate(nil)
    }
    
    @objc func toggleFPS() {
        showFPS.toggle()
        setupStatusBarItem() // refresh menu checkmark
        refreshOverlayContent()
    }
    
    @objc func toggleEditorMode() {
        editorMode.toggle()
        setupStatusBarItem()

        // Show or hide editor overlay window
        if editorMode {
            // Hide keystroke overlay to avoid duplicates
            keystrokeOverlayWindow?.orderOut(nil)
            editorOverlayWindow?.ignoresMouseEvents = false
            editorOverlayWindow?.makeKeyAndOrderFront(nil)
            editorOverlayWindow?.orderFrontRegardless()
        } else {
            // Show keystroke overlay
            keystrokeOverlayWindow?.makeKeyAndOrderFront(nil)
            keystrokeOverlayWindow?.orderFrontRegardless()
            editorOverlayWindow?.ignoresMouseEvents = true
            editorOverlayWindow?.orderOut(nil)
        }

        refreshOverlayContent()

        // Reset editor state when entering editor mode
        if editorMode {
            editorState.mode = .idle
            editorState.selectedID = nil
        }
    }

    // Removed duplicate toggleOverlay method to fix redeclaration error

    @objc func exportPreset() {
        let dialog = NSSavePanel()
        dialog.title = "Save preset file"
        dialog.allowedFileTypes = ["json"]
        dialog.nameFieldStringValue = "MyPreset"

        if dialog.runModal() == .OK, let url = dialog.url {
            editorState.exportPreset(name: url.deletingPathExtension().lastPathComponent, windowSize: NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080))
        }
    }

    @objc func loadPreset() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a preset file"
        dialog.allowedFileTypes = ["json"]
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false

        if dialog.runModal() == .OK, let url = dialog.url {
            editorState.loadPreset(from: url)
            refreshOverlayContent()
        }
    }

    @objc func addSpaceBarPreset() {
        editorState.addSpaceBarPreset()
        refreshOverlayContent()
    }

    @objc func addWASDPreset() {
        editorState.addWASDPreset()
        refreshOverlayContent()
    }

    @objc func addMouseButtonsPreset() {
        editorState.addMouseButtonsPreset()
        refreshOverlayContent()
    }


    
    func toggleOverlay() {
        guard let keystrokeOverlayWindow = keystrokeOverlayWindow else { return }

        keystrokeOverlayVisible.toggle()
        if keystrokeOverlayVisible {
            print("Showing keystroke overlay window")
            keystrokeOverlayWindow.level = .floating
            keystrokeOverlayWindow.ignoresMouseEvents = !editorMode
            keystrokeOverlayWindow.makeKeyAndOrderFront(nil)
            keystrokeOverlayWindow.orderFrontRegardless()
        } else {
            print("Hiding keystroke overlay window")
            keystrokeOverlayWindow.orderOut(nil)
        }
    }
    
    func checkAccessibilityPermissions() {
        // Request Accessibility permissions with a system prompt if not already granted
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        print("Accessibility trusted: \(trusted)")
        if !trusted {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "This app needs accessibility permissions to monitor keystrokes. Please enable \"\(Bundle.main.bundleName ?? "Keystroke")\" in System Settings > Privacy & Security > Accessibility."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Cancel")
            
            // Fix the window level issue by adjusting the alert window
            if let window = alert.window as? NSPanel {
                window.level = .modalPanel
            }
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    private func handleEditorModeChange(_ mode: EditorState.Mode) {
        // Handle editor mode changes without closing the editor
        // The editor should stay open even when adding keys
    }
}

// Simple grid overlay used in editor mode
struct GridOverlay: View {
    let cell: CGFloat
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                var x: CGFloat = 0
                while x <= w {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: h))
                    x += cell
                }
                var y: CGFloat = 0
                while y <= h {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: w, y: y))
                    y += cell
                }
            }
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}



extension Bundle {
    var bundleName: String? {
        return infoDictionary?[kCFBundleNameKey as String] as? String
    }
}
