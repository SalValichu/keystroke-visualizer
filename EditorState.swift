import Foundation
import SwiftUI

final class EditorState: ObservableObject {
    enum Mode {
        case idle
        case addingKey
    }
    
    // MARK: - Undo/Redo
    enum EditAction {
        case add(Item)
        case remove(Item)
        case update(old: Item, new: Item)
        case removeAll([Item])
    }

    struct Item: Identifiable, Codable {
        enum ItemType: String, Codable { case key, wide, bar }
        let id: UUID
        var type: ItemType
        var label: String
        var codeToken: String? // e.g., "W", "SPACE", "LSHIFT"
        var frame: CGRect // in points within the overlay window
    }

    @Published var items: [Item] = []
    @Published var mode: Mode = .idle {
        didSet {
            onModeChange?(mode)
        }
    }
    @Published var selectedID: UUID?
    @Published var gridSize: CGFloat = 12
    
    // Undo/Redo stacks
    private var undoStack: [EditAction] = []
    private var redoStack: [EditAction] = []
    private var isUndoingOrRedoing = false

    var onModeChange: ((Mode) -> Void)?

    init() {
        // Start with empty keys; no default keys on startup
        items = []
    }

    // Add preset keys for space bar
    func addSpaceBarPreset() {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        let keySize: CGFloat = 52
        let spacing: CGFloat = 8
        let width = 3 * keySize + 2 * spacing
        let height: CGFloat = 26
        let centerX = screenSize.width / 2 - width / 2
        let centerY = screenSize.height / 2 - height / 2
        addKey(token: "SPACE", label: "SPACE", at: CGPoint(x: centerX, y: centerY), size: CGSize(width: width, height: height))
    }

    // Add preset keys for WASD in triangle format
    func addWASDPreset() {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        let keySize: CGFloat = 52
        let spacing: CGFloat = 8
        let baseX = screenSize.width / 2 - keySize - spacing / 2
        let baseY = screenSize.height / 2 - keySize - spacing / 2
        addKey(token: "W", label: "W", at: CGPoint(x: baseX + keySize + spacing, y: baseY + 2 * (keySize + spacing)), size: CGSize(width: keySize, height: keySize))
        addKey(token: "A", label: "A", at: CGPoint(x: baseX, y: baseY + keySize + spacing), size: CGSize(width: keySize, height: keySize))
        addKey(token: "S", label: "S", at: CGPoint(x: baseX + keySize + spacing, y: baseY + keySize + spacing), size: CGSize(width: keySize, height: keySize))
        addKey(token: "D", label: "D", at: CGPoint(x: baseX + 2 * (keySize + spacing), y: baseY + keySize + spacing), size: CGSize(width: keySize, height: keySize))
    }

    // Add preset keys for LMB and RMB with CPS
    func addMouseButtonsPreset() {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        let spacing: CGFloat = 4
        let width: CGFloat = 75
        let height: CGFloat = 36
        let baseX = screenSize.width / 2 - width - spacing / 2
        let baseY = screenSize.height / 2 - height / 2
        addKey(token: "LMB", label: "LMB", at: CGPoint(x: baseX, y: baseY), size: CGSize(width: width, height: height))
        addKey(token: "RMB", label: "RMB", at: CGPoint(x: baseX + width + spacing, y: baseY), size: CGSize(width: width, height: height))
    }

    func addKey(token: String, label: String, at origin: CGPoint, size: CGSize) {
        let snapped = snap(origin)
        let rect = CGRect(origin: snapped, size: size)
        let item = Item(id: UUID(), type: .key, label: label, codeToken: token, frame: rect)

        // Check if item already exists to prevent duplication or update
        if let index = items.firstIndex(where: { $0.codeToken == token }) {
            // Update existing item
            let oldItem = items[index]
            items[index].frame = rect
            items[index].label = label
            let newItem = items[index]

            // Add to undo stack if not currently undoing/redoing
            if !isUndoingOrRedoing {
                undoStack.append(.update(old: oldItem, new: newItem))
                redoStack.removeAll()
            }
        } else {
            // Add new item
            items.append(item)

            // Add to undo stack if not currently undoing/redoing
            if !isUndoingOrRedoing {
                undoStack.append(.add(item))
                redoStack.removeAll()
            }
        }
    }

    func updatePosition(for id: UUID, to origin: CGPoint) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        let oldItem = items[idx]
        items[idx].frame.origin = snap(origin)
        let newItem = items[idx]
        
        // Add to undo stack if not currently undoing/redoing
        if !isUndoingOrRedoing {
            undoStack.append(.update(old: oldItem, new: newItem))
            redoStack.removeAll()
        }
    }

    func resize(for id: UUID, deltaWidth: CGFloat) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        let oldItem = items[idx]
        var width = items[idx].frame.size.width + deltaWidth
        width = max(gridSize, round(width / gridSize) * gridSize)
        items[idx].frame.size.width = width
        let newItem = items[idx]
        
        // Add to undo stack if not currently undoing/redoing
        if !isUndoingOrRedoing {
            undoStack.append(.update(old: oldItem, new: newItem))
            redoStack.removeAll()
        }
    }

    func snap(_ p: CGPoint) -> CGPoint {
        CGPoint(x: round(p.x / gridSize) * gridSize,
                y: round(p.y / gridSize) * gridSize)
    }

    func updateLabel(for id: UUID, to newLabel: String) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        let oldItem = items[idx]
        items[idx].label = newLabel
        let newItem = items[idx]
        
        // Add to undo stack if not currently undoing/redoing
        if !isUndoingOrRedoing {
            undoStack.append(.update(old: oldItem, new: newItem))
            redoStack.removeAll()
        }
    }

    func removeItem(id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        let item = items[idx]
        items.remove(at: idx)
        
        // Add to undo stack if not currently undoing/redoing
        if !isUndoingOrRedoing {
            undoStack.append(.remove(item))
            redoStack.removeAll()
        }
    }

    // Save current layout to session
    func saveSession() {
        do {
            let preset = PresetExport(name: "TemporarySession", items: items, windowSize: CGSize(width: 1920, height: 1080), gridSize: gridSize)
            let data = try JSONEncoder().encode(preset)
            let url = EditorState.temporarySessionURL()!
            try data.write(to: url)
            print("Temporary session saved to: \(url.path)")
        } catch {
            print("Failed to save temporary session: \(error)")
        }
    }

    // Load current layout from session
    func loadSession() {
        // Deprecated: now loading from temporary session or UserDefaults fallback
        guard let data = UserDefaults.standard.data(forKey: "EditorSessionItems") else { return }
        do {
            items = try JSONDecoder().decode([Item].self, from: data)
            print("Session loaded with \(items.count) items")
        } catch {
            print("Failed to load session: \(error)")
        }
    }

    // Export minimal preset JSON to Application Support
    func exportPreset(name: String = "Exported", windowSize: CGSize) {
        let preset = PresetExport(name: name, items: items, windowSize: windowSize, gridSize: gridSize)
        do {
            let data = try JSONEncoder().encode(preset)
            let fm = FileManager.default
            let appSupport = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dir = appSupport.appendingPathComponent("KeystrokeVisualizer/presets", isDirectory: true)
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
            let date = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
            let url = dir.appendingPathComponent("\(name)-\(date).json")
            try data.write(to: url)
            print("Preset exported to: \(url.path)")
        } catch {
            print("Export failed: \(error)")
        }
    }

    // Temporary session file URL in Application Support
    static func temporarySessionURL() -> URL? {
        do {
            let fm = FileManager.default
            let appSupport = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dir = appSupport.appendingPathComponent("KeystrokeVisualizer/temp", isDirectory: true)
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
            return dir.appendingPathComponent("tempSession.json")
        } catch {
            print("Failed to get temporary session URL: \(error)")
            return nil
        }
    }

    // Remove temporary session folder on quit
    static func removeTemporarySession() {
        do {
            let fm = FileManager.default
            let appSupport = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let dir = appSupport.appendingPathComponent("KeystrokeVisualizer/temp", isDirectory: true)
            if fm.fileExists(atPath: dir.path) {
                try fm.removeItem(at: dir)
                print("Temporary session folder removed")
            }
        } catch {
            print("Failed to remove temporary session folder: \(error)")
        }
    }

    // Load preset from JSON file
    func loadPreset(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let preset = try JSONDecoder().decode(PresetExport.self, from: data)
            items = preset.items
            gridSize = preset.gridSize
            print("Preset loaded from: \(url.path)")
        } catch {
            print("Load failed: \(error)")
        }
    }

    // Add default hardcoded keys (Minecraft-style: W, A, S, D, SPACE, LMB, RMB)
    private func addDefaultKeys() {
        let keySize: CGFloat = 52
        let spacing: CGFloat = 8

        // Bottom row: Mouse CPS
        addKey(token: "LMB", label: "LMB", at: CGPoint(x: 0, y: 0), size: CGSize(width: 75, height: 56))
        addKey(token: "RMB", label: "RMB", at: CGPoint(x: 110 + spacing, y: 0), size: CGSize(width: 75, height: 56))

        // Space bar
        addKey(token: "SPACE", label: "SPACE", at: CGPoint(x: 0, y: 56 + spacing), size: CGSize(width: 3 * keySize + 2 * spacing, height: 26))

        // A S D row
        addKey(token: "A", label: "A", at: CGPoint(x: 0, y: 56 + spacing + 26 + spacing), size: CGSize(width: keySize, height: keySize))
        addKey(token: "S", label: "S", at: CGPoint(x: keySize + spacing, y: 56 + spacing + 26 + spacing), size: CGSize(width: keySize, height: keySize))
        addKey(token: "D", label: "D", at: CGPoint(x: 2 * (keySize + spacing), y: 56 + spacing + 26 + spacing), size: CGSize(width: keySize, height: keySize))

        // W row
        addKey(token: "W", label: "W", at: CGPoint(x: keySize + spacing, y: 56 + spacing + 26 + spacing + keySize + spacing), size: CGSize(width: keySize, height: keySize))
    }
    
    // Clear all items
    func clearAll() {
        let oldItems = items
        items.removeAll()
        
        // Add to undo stack if not currently undoing/redoing
        if !isUndoingOrRedoing {
            undoStack.append(.removeAll(oldItems))
            redoStack.removeAll()
        }
    }
    
    // Update an entire item
    func updateItem(_ updatedItem: Item) {
        guard let index = items.firstIndex(where: { $0.id == updatedItem.id }) else { return }
        let oldItem = items[index]
        items[index] = updatedItem
        
        // Add to undo stack if not currently undoing/redoing
        if !isUndoingOrRedoing {
            undoStack.append(.update(old: oldItem, new: updatedItem))
            redoStack.removeAll()
        }
    }
    
    // Undo functionality
    func undo() {
        guard !undoStack.isEmpty else { return }
        
        isUndoingOrRedoing = true
        let action = undoStack.removeLast()
        
        switch action {
        case .add(let item):
            items.removeAll { $0.id == item.id }
            redoStack.append(.add(item))
        case .remove(let item):
            items.append(item)
            redoStack.append(.remove(item))
        case .update(let old, _):
            if let index = items.firstIndex(where: { $0.id == old.id }) {
                let newItem = items[index]
                items[index] = old
                redoStack.append(.update(old: newItem, new: old))
            }
        case .removeAll(let itemsList):
            items = itemsList
            redoStack.append(.removeAll([]))
        }
        
        isUndoingOrRedoing = false
    }
    
    // Redo functionality
    func redo() {
        guard !redoStack.isEmpty else { return }
        
        isUndoingOrRedoing = true
        let action = redoStack.removeLast()
        
        switch action {
        case .add(let item):
            items.append(item)
            undoStack.append(.add(item))
        case .remove(let item):
            items.removeAll { $0.id == item.id }
            undoStack.append(.remove(item))
        case .update(_, let new):
            if let index = items.firstIndex(where: { $0.id == new.id }) {
                let oldItem = items[index]
                items[index] = new
                undoStack.append(.update(old: oldItem, new: new))
            }
        case .removeAll:
            let oldItems = items
            items.removeAll()
            undoStack.append(.removeAll(oldItems))
        }
        
        isUndoingOrRedoing = false
    }
    
    // Check if undo/redo is available
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
}

// Minimal export container
struct PresetExport: Codable {
    var name: String
    var items: [EditorState.Item]
    var windowWidth: CGFloat
    var windowHeight: CGFloat
    var gridSize: CGFloat

    init(name: String, items: [EditorState.Item], windowSize: CGSize, gridSize: CGFloat) {
        self.name = name
        self.items = items
        self.windowWidth = windowSize.width
        self.windowHeight = windowSize.height
        self.gridSize = gridSize
    }
    
    var windowSize: CGSize {
        CGSize(width: windowWidth, height: windowHeight)
    }
}