import Cocoa
import SwiftUI
import ApplicationServices

public class InputManager: ObservableObject {
    public enum MouseButton {
        case left
        case right
        case center
        case button3
        case button4
        case button5
    }

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var leftClickTimes: [Date] = []
    private var rightClickTimes: [Date] = []
    private var cpsTimer: Timer?

    @Published public var pressedKeys: Set<CGKeyCode> = []
    @Published public var pressedMouseButtons: Set<MouseButton> = []
    @Published public var leftCPS: Double = 0
    @Published public var rightCPS: Double = 0
    @Published public var lastMouseButtonDown: MouseButton?
    @Published public var lastKeyDownCode: CGKeyCode?

    public init() {
        startEventTap()
        startCPSTimer()
    }

    deinit {
        stopEventTap()
        cpsTimer?.invalidate()
    }

    private func startCPSTimer() {
        cpsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let now = Date()
            self.leftClickTimes = self.leftClickTimes.filter { now.timeIntervalSince($0) <= 2 }
            self.rightClickTimes = self.rightClickTimes.filter { now.timeIntervalSince($0) <= 2 }
            self.leftCPS = Double(self.leftClickTimes.filter { now.timeIntervalSince($0) <= 1 }.count)
            self.rightCPS = Double(self.rightClickTimes.filter { now.timeIntervalSince($0) <= 1 }.count)
        }
    }

    private func startEventTap() {
        // Create event mask for key and mouse events
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue) |
                   CGEventMask(1 << CGEventType.keyUp.rawValue) |
                   CGEventMask(1 << CGEventType.leftMouseDown.rawValue) |
                   CGEventMask(1 << CGEventType.leftMouseUp.rawValue) |
                   CGEventMask(1 << CGEventType.rightMouseDown.rawValue) |
                   CGEventMask(1 << CGEventType.rightMouseUp.rawValue)

        // Create event tap
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                     place: .headInsertEventTap,
                                     options: .listenOnly,
                                     eventsOfInterest: mask,
                                     callback: eventTapCallback,
                                     userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
    }

    private let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, userInfo) -> Unmanaged<CGEvent>? in
        guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
        let inputManager = Unmanaged<InputManager>.fromOpaque(userInfo).takeUnretainedValue()

        switch type {
        case .keyDown:
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            inputManager.pressedKeys.insert(CGKeyCode(keyCode))
            inputManager.lastKeyDownCode = CGKeyCode(keyCode)
        case .keyUp:
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            inputManager.pressedKeys.remove(CGKeyCode(keyCode))
        case .leftMouseDown:
            inputManager.pressedMouseButtons.insert(.left)
            inputManager.lastMouseButtonDown = .left
            inputManager.leftClickTimes.append(Date())
        case .leftMouseUp:
            inputManager.pressedMouseButtons.remove(.left)
        case .rightMouseDown:
            inputManager.pressedMouseButtons.insert(.right)
            inputManager.lastMouseButtonDown = .right
            inputManager.rightClickTimes.append(Date())
        case .rightMouseUp:
            inputManager.pressedMouseButtons.remove(.right)
        default:
            break
        }

        return Unmanaged.passUnretained(event)
    }

    func stopEventTap() {
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        // CFRelease is not needed in Swift as ARC handles it
    }
}
