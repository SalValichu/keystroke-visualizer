import Cocoa
import SwiftUI

class LayoutManager: ObservableObject {
    @Published var keys: [KeyConfig] = []
    
    struct KeyConfig: Identifiable {
        let id = UUID()
        let keyCode: CGKeyCode
        var name: String
        var position: CGPoint
        var size: CGSize
        var color: Color
    }
    
    init() {
        print("LayoutManager init")
        setupDefaultLayout()
    }
    
    private func setupDefaultLayout() {
        let keySize: CGFloat = 60
        let margin: CGFloat = 20
        let keyColor: Color = .blue
        let mouseColor: Color = .red
        
        // Place keys near bottom-left corner of the screen
        let baseX: CGFloat = margin + keySize
        let baseY: CGFloat = margin + keySize

        // WASD layout
        keys.append(KeyConfig(
            keyCode: 13, // W
            name: "W",
            position: CGPoint(x: baseX, y: baseY + keySize + margin),
            size: CGSize(width: keySize, height: keySize),
            color: keyColor
        ))
        
        keys.append(KeyConfig(
            keyCode: 0, // A
            name: "A",
            position: CGPoint(x: baseX - keySize - margin, y: baseY),
            size: CGSize(width: keySize, height: keySize),
            color: keyColor
        ))
        
        keys.append(KeyConfig(
            keyCode: 1, // S
            name: "S",
            position: CGPoint(x: baseX, y: baseY),
            size: CGSize(width: keySize, height: keySize),
            color: keyColor
        ))
        
        keys.append(KeyConfig(
            keyCode: 2, // D
            name: "D",
            position: CGPoint(x: baseX + keySize + margin, y: baseY),
            size: CGSize(width: keySize, height: keySize),
            color: keyColor
        ))
        
        // Space bar below
        keys.append(KeyConfig(
            keyCode: 49, // Space
            name: "Space",
            position: CGPoint(x: baseX, y: baseY - keySize - margin),
            size: CGSize(width: keySize * 3 + margin * 2, height: keySize * 0.6),
            color: .gray
        ))
        
        // Mouse buttons to the right
        keys.append(KeyConfig(
            keyCode: 999, // Left mouse button (custom code)
            name: "LMB",
            position: CGPoint(x: baseX + (keySize * 5), y: baseY),
            size: CGSize(width: keySize, height: keySize),
            color: mouseColor
        ))
        
        keys.append(KeyConfig(
            keyCode: 1000, // Right mouse button (custom code)
            name: "RMB",
            position: CGPoint(x: baseX + (keySize * 6) + margin, y: baseY),
            size: CGSize(width: keySize, height: keySize),
            color: mouseColor
        ))
        
        keys.append(KeyConfig(
            keyCode: 1001, // Middle mouse button (custom code)
            name: "MMB",
            position: CGPoint(x: baseX + (keySize * 5.5), y: baseY + keySize + margin),
            size: CGSize(width: keySize, height: keySize),
            color: mouseColor
        ))
        
        print("Created \(keys.count) keys in layout")
        for key in keys {
            print("Key: \(key.name) at (\(key.position.x), \(key.position.y))")
        }
    }
    
    func getKey(for keyCode: CGKeyCode) -> KeyConfig? {
        return keys.first { $0.keyCode == keyCode }
    }
    
    func isKeyPressed(_ keyCode: CGKeyCode) -> Bool {
        // This will be implemented in the view model
        return false
    }
}