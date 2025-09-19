import SwiftUI

@available(macOS 12.0, *)
struct EditorCanvasView: View {
    @ObservedObject var editor: EditorState
    @ObservedObject var input: InputManager
    var showBackground: Bool

    @State private var hoverPoint: CGPoint = .zero
    @State private var editingItemID: UUID? = nil
    @State private var editingLabel: String = ""
    @FocusState private var isEditingFocused: Bool
    @State private var showCustomizePanel = false
    @State private var tempItem: EditorState.Item?
    @State private var addingKeyOrigin: CGPoint = CGPoint(x: 20, y: 100)
    @State private var showPresetNameAlert = false
    @State private var presetName = ""
    @State private var showPresetsPanel = false
    @State private var availablePresets: [String] = []
    @State private var lastModeChangeTime: Date = Date()
    @State private var saveFeedback: String? = nil

    // Multi-selection state
    @State private var multiSelectedIDs: Set<UUID> = []
    @State private var multiSelectStartPoint: CGPoint? = nil
    @State private var multiSelectCurrentPoint: CGPoint? = nil

    private let defaultKeySize = CGSize(width: 52, height: 52)
    private let keySpacing: CGFloat = 10

    // 新增常量用于定义鼠标按钮尺寸
    private let mouseButtonSize = CGSize(width: 120, height: 36) // 水平宽度与空格键相同，垂直高度更小

    var body: some View {
        ZStack(alignment: .top) {
            // Items
            ForEach(editor.items) { item in
                itemContainerView(for: item)
            }



            // Top center buttons
            topCenterButtonsView

            // Remove customization panel, presets panel, and preset name alert when adding key
            if editor.mode != .addingKey {
                if showCustomizePanel, let item = tempItem {
                    customizationPanel(for: item)
                }
                
                if showPresetsPanel {
                    presetsPanel()
                }
                
                if showPresetNameAlert {
                    presetNameAlert()
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if multiSelectStartPoint == nil {
                        multiSelectStartPoint = value.startLocation
                        multiSelectCurrentPoint = value.location
                    } else {
                        multiSelectCurrentPoint = value.location
                    }
                    updateMultiSelection()
                }
                .onEnded { _ in
                    multiSelectStartPoint = nil
                    multiSelectCurrentPoint = nil
                }
        )
        .background(GeometryReader { geo in
            Color.clear
                .onReceive(input.$lastKeyDownCode) { code in
                    if editor.mode == .addingKey, let keyCode = code {
                        handleKeyDown(keyCode, in: geo.size)
                    }
                }
                .onReceive(input.$lastMouseButtonDown) { button in
                    if editor.mode == .addingKey, let mouseButton = button {
                        handleMouseDown(mouseButton, in: geo.size)
                    }
                }
                .onTapGesture {
                    // Deselect when clicking on background
                    editor.selectedID = nil
                    editingItemID = nil
                    multiSelectedIDs.removeAll()
                }
        })
        .onAppear {
            // Reset the adding key origin when editor appears
            addingKeyOrigin = CGPoint(x: 20, y: 100)
        }
    }

    private func updateMultiSelection() {
        guard let start = multiSelectStartPoint, let current = multiSelectCurrentPoint else { return }
        let rect = CGRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
        multiSelectedIDs = Set(editor.items.filter { item in
            rect.intersects(item.frame)
        }.map { $0.id })
        editor.selectedID = nil
        editingItemID = nil
        tempItem = nil
        showCustomizePanel = false
    }

    private var topCenterButtonsView: some View {
        HStack(spacing: 16) {
            Button(action: {
                editor.mode = .idle
                editor.selectedID = nil
                editingItemID = nil
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(editor.mode == .idle && editor.selectedID != nil ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(editor.mode == .idle && editor.selectedID != nil ? .white : .primary)
                .cornerRadius(8)
            }
            .help("Select and edit existing keys")

            Button(action: {
                editor.mode = .addingKey
                editor.selectedID = nil
                editingItemID = nil
                lastModeChangeTime = Date()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Key")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(editor.mode == .addingKey ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(editor.mode == .addingKey ? .white : .primary)
                .cornerRadius(8)
            }
            .help("Press any key to add it to the overlay")

            Button(action: {
                editor.undo()
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.left")
                    Text("Undo")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .disabled(!editor.canUndo)

            Button(action: {
                editor.redo()
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.right")
                    Text("Redo")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .disabled(!editor.canRedo)

            Button(action: {
                editor.saveSession()
                saveFeedback = "Saved!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    saveFeedback = nil
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            if let feedback = saveFeedback {
                Text(feedback)
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.leading, 8)
            }

            Button(action: {
                presetName = "My Preset"
                showPresetNameAlert = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .help("Export current layout as a preset")

            Button(action: {
                showPresetsPanel = true
                loadAvailablePresets()
            }) {
                HStack {
                    Image(systemName: "folder")
                    Text("Presets")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            Button(action: { editor.clearAll() }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .padding(.top, 16)
    }

    private func itemContainerView(for item: EditorState.Item) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(item.id == editor.selectedID ? Color.blue.opacity(0.3) : Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(item.id == editor.selectedID ? Color.blue.opacity(0.8) : Color.white.opacity(0.3), lineWidth: item.id == editor.selectedID ? 2 : 1)
                )
            if editingItemID == item.id {
                TextField("", text: $editingLabel, onCommit: {
                    editor.updateLabel(for: item.id, to: editingLabel)
                    editingItemID = nil
                })
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: item.frame.width - 10, height: item.frame.height - 10)
                .background(Color.black.opacity(0.7))
                .cornerRadius(6)
                .focused($isEditingFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isEditingFocused = true
                    }
                }
            } else {
                Text(item.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Resize handle at bottom right
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.5))
                .frame(width: 10, height: 10)
                .position(x: item.frame.width - 8, y: item.frame.height - 8)
        }
        .frame(width: item.frame.width, height: item.frame.height)
        .position(x: item.frame.origin.x + item.frame.width/2,
                  y: item.frame.origin.y + item.frame.height/2)
        .gesture(dragGesture(for: item))
        .gesture(resizeGesture(for: item))
        .contextMenu {
            Button("Edit Label") {
                editingItemID = item.id
                editingLabel = item.label
            }
            Button("Customize") {
                tempItem = item
                showCustomizePanel = true
            }
            Button("Delete", role: .destructive) {
                editor.removeItem(id: item.id)
            }
        }
        .onTapGesture {
            editor.selectedID = item.id
        }
    }
    

    
    private func customizationPanel(for item: EditorState.Item) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customize Key")
                .font(.headline)
                .foregroundColor(.white)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                if multiSelectedIDs.count <= 1 {
                    Text("Label")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    TextField("Label", text: Binding(
                        get: { item.label },
                        set: { newValue in
                            if let tempItem = tempItem {
                                // Create a new item with updated label
                                self.tempItem = EditorState.Item(
                                    id: tempItem.id,
                                    type: tempItem.type,
                                    label: newValue,
                                    codeToken: tempItem.codeToken,
                                    frame: tempItem.frame
                                )
                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text("Multiple items selected")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Size")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                HStack {
                    Button("Small") {
                        updateItemSize(item, CGSize(width: 40, height: 40))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    
                    Button("Medium") {
                        updateItemSize(item, CGSize(width: 52, height: 52))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    
                    Button("Large") {
                        updateItemSize(item, CGSize(width: 70, height: 70))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Type")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                HStack {
                    Button("Key") {
                        updateItemType(item, .key)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    
                    Button("Wide") {
                        updateItemType(item, .wide)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    
                    Button("Bar") {
                        updateItemType(item, .bar)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                }
            }
            
            if multiSelectedIDs.count > 1 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transparency")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Slider(value: Binding(
                        get: {
                            // Average transparency of selected items
                            let alphas = editor.items.filter { multiSelectedIDs.contains($0.id) }.map { item in
                                // Assuming transparency stored in label or add a new property if needed
                                1.0 // Placeholder, actual transparency property needed
                            }
                            return alphas.isEmpty ? 1.0 : alphas.reduce(0, +) / Double(alphas.count)
                        },
                        set: { newValue in
                            // Update transparency for all selected items
                            for id in multiSelectedIDs {
                                if let index = editor.items.firstIndex(where: { $0.id == id }) {
                                    let item = editor.items[index]
                                    // Update transparency property here
                                    // Placeholder: no transparency property in current model
                                    editor.updateItem(item)
                                }
                            }
                        }
                    ), in: 0...1)
                }
            }
            
            HStack {
                Spacer()
                Button("Cancel") {
                    showCustomizePanel = false
                    tempItem = nil
                }
                .keyboardShortcut(.cancelAction)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
                
                Button("Apply") {
                    if let updatedItem = tempItem {
                        editor.updateItem(updatedItem)
                        showCustomizePanel = false
                        tempItem = nil
                    }
                }
                .keyboardShortcut(.defaultAction)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding()
        .frame(width: 300)
        .background(Color.gray.opacity(0.9))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
    
    private func presetsPanel() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Available Presets")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    showPresetsPanel = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            
            Divider()
            
            if availablePresets.isEmpty {
                Text("No presets found")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, minHeight: 50)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(availablePresets, id: \.self) { preset in
                            Button(action: {
                                loadPreset(named: preset)
                            }) {
                                HStack {
                                    Text(preset.replacingOccurrences(of: ".json", with: ""))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
            
            HStack {
                Spacer()
                Button("Close") {
                    showPresetsPanel = false
                }
                .keyboardShortcut(.cancelAction)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
            }
        }
        .padding()
        .frame(width: 350)
        .background(Color.gray.opacity(0.9))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
    
    private func presetNameAlert() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Preset")
                .font(.headline)
                .foregroundColor(.white)
            
            Divider()
            
            Text("Enter a name for your preset:")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            TextField("Preset Name", text: $presetName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Spacer()
                Button("Cancel") {
                    showPresetNameAlert = false
                    presetName = ""
                }
                .keyboardShortcut(.cancelAction)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
                
                Button("Export") {
                    exportPreset(named: presetName)
                    showPresetNameAlert = false
                    presetName = ""
                }
                .keyboardShortcut(.defaultAction)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding()
        .frame(width: 350)
        .background(Color.gray.opacity(0.9))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }

    private func handleKeyDown(_ keyCode: CGKeyCode, in container: CGSize) {
        guard editor.mode == .addingKey else { return }

        let token = KeyCodes.token(from: keyCode) ?? "Key\(keyCode)"
        let label = token

        // If key already exists, update its position instead of adding duplicate
        if let existingIndex = editor.items.firstIndex(where: { $0.codeToken == token }) {
            let existingItem = editor.items[existingIndex]
            let newFrame = CGRect(origin: addingKeyOrigin, size: existingItem.frame.size)
            var updatedItem = existingItem
            updatedItem.frame = newFrame
            editor.updateItem(updatedItem)
        } else {
            // Place new item near top-left with snap
            editor.addKey(token: token, label: label, at: addingKeyOrigin, size: defaultKeySize)
        }

        // Update position for next key
        addingKeyOrigin.x += defaultKeySize.width + keySpacing
        if addingKeyOrigin.x > container.width - defaultKeySize.width - 20 {
            addingKeyOrigin.x = 20
            addingKeyOrigin.y += defaultKeySize.height + keySpacing
        }

        // Exit adding mode after one key added
        editor.mode = .idle
    }
    
    private func handleMouseDown(_ mouseButton: InputManager.MouseButton, in container: CGSize) {
        guard editor.mode == .addingKey else { return }

        // Prevent adding key immediately after mode change to avoid button click triggering
        let timeSinceModeChange = Date().timeIntervalSince(lastModeChangeTime)
        guard timeSinceModeChange > 0.2 else { return }

        let token = KeyCodes.token(from: mouseButton)
        let label = token

        // Prevent duplicate keys
        if editor.items.contains(where: { $0.codeToken == token }) {
            editor.mode = .idle
            return
        }

        // Place new item near top-left with snap
        editor.addKey(token: token, label: label, at: addingKeyOrigin, size: mouseButtonSize) // 使用 mouseButtonSize

        // Update position for next key
        addingKeyOrigin.x += mouseButtonSize.width + keySpacing // 使用 mouseButtonSize 的宽度
        if addingKeyOrigin.x > container.width - mouseButtonSize.width - 20 {
            addingKeyOrigin.x = 20
            addingKeyOrigin.y += mouseButtonSize.height + keySpacing // 使用 mouseButtonSize 的高度
        }

        // Exit adding mode after one key added
        editor.mode = .idle
    }

    private func dragGesture(for item: EditorState.Item) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let newOrigin = CGPoint(x: value.location.x - item.frame.width/2,
                                        y: value.location.y - item.frame.height/2)
                editor.updatePosition(for: item.id, to: newOrigin)
            }
    }
    
    private func resizeGesture(for item: EditorState.Item) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                // Check if drag is near bottom-right corner (resize area)
                let itemBottomRight = CGPoint(
                    x: item.frame.origin.x + item.frame.width,
                    y: item.frame.origin.y + item.frame.height
                )
                
                let distance = sqrt(
                    pow(value.startLocation.x - itemBottomRight.x, 2) +
                    pow(value.startLocation.y - itemBottomRight.y, 2)
                )
                
                // Only resize if we started near the bottom-right corner
                if distance < 20 {
                    let deltaWidth = value.location.x - (item.frame.origin.x + item.frame.width)
                    let deltaHeight = value.location.y - (item.frame.origin.y + item.frame.height)
                    
                    var newWidth = item.frame.width + deltaWidth
                    var newHeight = item.frame.height + deltaHeight
                    
                    // Apply minimum size constraints
                    newWidth = max(30, newWidth)
                    newHeight = max(30, newHeight)
                    
                    // Apply grid snapping
                    newWidth = round(newWidth / editor.gridSize) * editor.gridSize
                    newHeight = round(newHeight / editor.gridSize) * editor.gridSize
                    
                    // Update item frame
                    var newFrame = item.frame
                    newFrame.size.width = newWidth
                    newFrame.size.height = newHeight
                    
                    if let index = editor.items.firstIndex(where: { $0.id == item.id }) {
                        var updatedItem = editor.items[index]
                        updatedItem.frame = newFrame
                        editor.updateItem(updatedItem)
                    }
                }
            }
    }

    private func exportPreset(named name: String) {
        // Estimate window size; ideally read from the host window
        let windowSize = CGSize(width: 400, height: 300)
        editor.exportPreset(name: name.isEmpty ? "Untitled" : name, windowSize: windowSize)
    }
    
    private func loadAvailablePresets() {
        do {
            let fm = FileManager.default
            let appSupport = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let dir = appSupport.appendingPathComponent("KeystrokeVisualizer/presets", isDirectory: true)
            
            if fm.fileExists(atPath: dir.path) {
                let files = try fm.contentsOfDirectory(atPath: dir.path)
                availablePresets = files.filter { $0.hasSuffix(".json") }
                    .sorted()
            } else {
                availablePresets = []
            }
        } catch {
            print("Failed to load presets: \(error)")
            availablePresets = []
        }
    }
    
    private func loadPreset(named name: String) {
        do {
            let fm = FileManager.default
            let appSupport = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let dir = appSupport.appendingPathComponent("KeystrokeVisualizer/presets", isDirectory: true)
            let fileURL = dir.appendingPathComponent(name)
            
            let data = try Data(contentsOf: fileURL)
            let preset = try JSONDecoder().decode(PresetExport.self, from: data)
            
            // Apply the preset
            editor.items = preset.items
            editor.gridSize = preset.gridSize
            
            showPresetsPanel = false
        } catch {
            print("Failed to load preset: \(error)")
            // Show an alert or error message
        }
    }
    
    // Helper functions for customization
    private func updateItemSize(_ item: EditorState.Item, _ size: CGSize) {
        if let tempItem = tempItem {
            self.tempItem = EditorState.Item(
                id: tempItem.id,
                type: tempItem.type,
                label: tempItem.label,
                codeToken: tempItem.codeToken,
                frame: CGRect(origin: tempItem.frame.origin, size: size)
            )
        }
    }
    
    private func updateItemType(_ item: EditorState.Item, _ type: EditorState.Item.ItemType) {
        if let tempItem = tempItem {
            self.tempItem = EditorState.Item(
                id: tempItem.id,
                type: type,
                label: tempItem.label,
                codeToken: tempItem.codeToken,
                frame: tempItem.frame
            )
        }
    }
}