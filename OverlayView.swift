import SwiftUI

// Clean Minecraft-style keystrokes overlay (black/grey & white)
struct KeystrokesOverlayView: View {
    @ObservedObject var inputManager: InputManager
    @ObservedObject var editorState: EditorState

    // macOS key codes (ANSI)
    private let kcW: CGKeyCode = 13
    private let kcA: CGKeyCode = 0
    private let kcS: CGKeyCode = 1
    private let kcD: CGKeyCode = 2
    private let kcSpace: CGKeyCode = 49
    private let kcQ: CGKeyCode = 12
    private let kcE: CGKeyCode = 14
    private let kcF: CGKeyCode = 3
    private let kcC: CGKeyCode = 8
    private let kcShiftL: CGKeyCode = 56
    private let kcCtrlL: CGKeyCode = 59
    private let kcCmdL: CGKeyCode = 55

    private let keySize: CGFloat = 52
    private let smallKeySize: CGFloat = 48

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Display all items from editorState (including default/hardcoded)
            ForEach(editorState.items) { item in
                CustomItemView(item: item, inputManager: inputManager)
                    .position(x: item.frame.midX, y: item.frame.midY)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear) // Ensure transparent background
    }

    private func isPressed(_ code: CGKeyCode) -> Bool {
        inputManager.pressedKeys.contains(code)
    }

    private func isPressed(for item: EditorState.Item) -> Bool {
        if let token = item.codeToken {
            if let code = KeyCodes.tokenToCode[token] {
                return isPressed(code)
            } else if token.hasPrefix("Key"), let codeValue = UInt32(String(token.dropFirst(3))) {
                return isPressed(CGKeyCode(codeValue))
            }
        }
        return false
    }
}

struct CustomItemView: View {
    let item: EditorState.Item
    @ObservedObject var inputManager: InputManager

    var body: some View {
        let pressed = isPressed(for: item)
        if item.codeToken == "LMB" {
            CPSCap(label: "LMB", pressed: pressed, cps: inputManager.leftCPS, width: item.frame.width, height: item.frame.height)
        } else if item.codeToken == "RMB" {
            CPSCap(label: "RMB", pressed: pressed, cps: inputManager.rightCPS, width: item.frame.width, height: item.frame.height)
        } else {
            let displayLabel = item.label
            switch item.type {
            case .key:
                KeyCap(label: displayLabel, pressed: pressed, w: item.frame.width, h: item.frame.height)
            case .wide:
                WideKey(label: displayLabel, pressed: pressed, width: item.frame.width)
            case .bar:
                KeyBar(label: displayLabel, pressed: pressed, width: item.frame.width, height: item.frame.height)
            }
        }
    }

    private func isPressed(_ code: CGKeyCode) -> Bool {
        inputManager.pressedKeys.contains(code)
    }

    private func isPressed(for item: EditorState.Item) -> Bool {
        if let token = item.codeToken {
            if let code = KeyCodes.tokenToCode[token] {
                return isPressed(code)
            } else if token.hasPrefix("Key"), let codeValue = UInt32(String(token.dropFirst(3))) {
                return isPressed(CGKeyCode(codeValue))
            } else if token == "LMB" {
                return inputManager.pressedMouseButtons.contains(.left)
            } else if token == "RMB" {
                return inputManager.pressedMouseButtons.contains(.right)
            }
        }
        return false
    }
}

// MARK: - Components

struct KeyCap: View {
    let label: String
    let pressed: Bool
    let w: CGFloat
    let h: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(pressed ? Color.white.opacity(0.95) : Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(pressed ? 0.95 : 0.25), lineWidth: 2)
                )
            Text(label)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(pressed ? .black : .white)
        }
        .frame(width: w, height: h)
        .animation(.easeOut(duration: 0.06), value: pressed)
    }
}

struct KeyBar: View {
    let label: String
    let pressed: Bool
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(pressed ? Color.white.opacity(0.95) : Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(pressed ? 0.95 : 0.25), lineWidth: 2)
                )
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(pressed ? .black : Color.white.opacity(0.92))
        }
        .frame(width: width, height: height)
        .animation(.easeOut(duration: 0.06), value: pressed)
    }
}

struct WideKey: View {
    let label: String
    let pressed: Bool
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(pressed ? Color.white.opacity(0.95) : Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(pressed ? 0.95 : 0.25), lineWidth: 1.5)
                )
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(pressed ? .black : .white)
        }
        .frame(width: width, height: 24)
        .animation(.easeOut(duration: 0.06), value: pressed)
    }
}

struct CPSCap: View {
    let label: String
    let pressed: Bool
    let cps: Double
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(pressed ? Color.white.opacity(0.95) : Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(pressed ? 0.95 : 0.25), lineWidth: 2)
                )
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text(String(format: "%.1f CPS", cps))
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .opacity(0.9)
            }
            .foregroundColor(pressed ? .black : .white)
        }
        .frame(width: width, height: height)
        .animation(.easeOut(duration: 0.06), value: pressed)
    }
}

struct GhostCap: View {
    let size: CGFloat
    var body: some View {
        Rectangle().fill(Color.clear).frame(width: size, height: size)
    }
}
