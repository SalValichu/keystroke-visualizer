import Foundation
import ApplicationServices
// Note: InputManager is in the same module, so no need for import

enum KeyCodes {
    static let tokenToCode: [String: CGKeyCode] = [
        "A": 0, "S": 1, "D": 2, "F": 3,
        "H": 4, "G": 5,
        "Z": 6, "X": 7, "C": 8, "V": 9,
        "B": 11,
        "Q": 12, "W": 13, "E": 14, "R": 15,
        "Y": 16, "T": 17,
        "1": 18, "2": 19, "3": 20, "4": 21, "5": 23,
        "6": 22, "7": 26, "8": 28, "9": 25, "0": 29,
        "RETURN": 36,
        "ESC": 53,
        "SPACE": 49,
        "TAB": 48,
        "CAPS": 57,
        "LSHIFT": 56, "RSHIFT": 60,
        "LCTRL": 59, "RCTRL": 62,
        "LALT": 58, "RALT": 61,
        "LCMD": 55, "RCMD": 54,
        "F1": 122, "F2": 120, "F3": 99, "F4": 118,
        "F5": 96, "F6": 97, "F7": 98, "F8": 100,
        "F9": 101, "F10": 109, "F11": 103, "F12": 111,
        "LEFT": 123, "RIGHT": 124, "DOWN": 125, "UP": 126
    ]

    static func token(from code: CGKeyCode) -> String? {
        for (k, v) in tokenToCode where v == code { return k }
        // For unknown keys, create a generic label
        return "Key\(code)"
    }

    static func token(from mouseButton: InputManager.MouseButton) -> String {
        switch mouseButton {
        case .left: return "LMB"
        case .right: return "RMB"
        case .center: return "MMB"
        case .button3: return "MB3"
        case .button4: return "MB4"
        case .button5: return "MB5"
        }
    }
}
