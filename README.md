# Keystroke Visualizer

A macOS application that visualizes keystrokes and mouse clicks on your screen. Perfect for presentations, tutorials, and screen recordings.

## Features

### Real-time Keystroke Visualization
- Displays keyboard keys and mouse clicks as they happen
- Customizable layout editor
- Save and export layouts
- Undo/Redo functionality

### Editor Mode
- Add, move, and customize keys
- Resize and reposition elements with grid snapping
- Context menu for quick actions
- Visual customization options

### Customization Options
1. **Key Types**:
   - Standard keys
   - Wide keys for modifiers (Shift, Ctrl, etc.)
   - Bar keys for spacebar

2. **Visual Customization**:
   - Change key labels
   - Adjust key sizes (Small, Medium, Large)
   - Position and alignment tools

3. **Layout Management**:
   - Save layouts automatically
   - Export layouts as JSON files
   - Clear all functionality

## Usage

### Basic Operation
1. The application runs in the menu bar (top right of your screen)
2. Click the keyboard icon to access the menu
3. Toggle the overlay on/off as needed
4. Enable Editor Mode to customize the layout

### Editor Mode Controls
1. **Add Key**: Click this button then press any key or mouse button to add it to the visualization
2. **Customize**: Right-click on any key and select "Customize" to change its appearance
3. **Move**: Drag keys to reposition them
4. **Edit**: Right-click on any key and select "Edit" to change its label
5. **Delete**: Right-click on any key and select "Delete" to remove it

### Toolbar Functions
- **Add Key**: Add a new key to the layout
- **Quit Editor**: Exit editor mode and return to visualization
- **Export**: Save the current layout as a JSON file
- **Save**: Save the current layout for this session
- **Clear All**: Remove all keys from the layout
- **Undo/Redo**: Revert or reapply changes

## Troubleshooting

### Modal Dialog Issues
If you encounter issues where modal dialogs (like Save confirmation) block the application:
- This has been fixed in the current version by properly managing window levels
- If problems persist, try quitting and restarting the application

### Accessibility Permissions
The app requires accessibility permissions to monitor keystrokes:
1. If prompted, grant accessibility permissions
2. If you missed the prompt, manually enable permissions in:
   System Settings > Privacy & Security > Accessibility > Keystroke Visualizer

## Technical Details

### Window Management
- Uses a transparent overlay window that covers the entire screen
- In visualization mode, the window ignores mouse events (click-through)
- In editor mode, the window accepts mouse events for interaction
- Properly manages window levels to avoid conflicts with other applications

### Data Persistence
- Layouts are automatically saved to user preferences
- Exported layouts are saved as JSON files in Application Support directory

### Performance
- Uses SwiftUI for efficient rendering
- Implements grid snapping for consistent layout
- Optimized for minimal CPU usage