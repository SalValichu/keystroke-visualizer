# Keystroke Visualizer

A clean, minimal keystroke visualizer for macOS that displays your keyboard and mouse inputs on screen. Perfect for screen recordings, tutorials, and presentations.

## Beta V1.0

This is a beta release. The FPS overlay feature is currently not available.

## Quick Start

Run these commands in your terminal:

```bash
git clone https://github.com/SalValichu/keystroke-visualizer.git
cd keystroke-visualizer
make
make run
```

You will be prompted for TWO system permissions:

1. Accessibility permissions (to monitor keystrokes)
2. Screen recording permissions (to display overlay)

After allowing both permissions, the app will close automatically.

Simply rerun:
```bash
make run
```

And then you're in!

## How to Use

Once the app is running:

- WASD keys will light up when pressed
- Space bar will show when pressed
- Mouse buttons will show when clicked

To customize the layout:
1. Click the keyboard icon in the menu bar
2. Select "Edit Mode"
3. Move and resize elements as needed
4. Click "Exit Edit Mode" when finished

To quit the app, click the keyboard icon in the menu bar and select "Quit".

## Building from Source

### Prerequisites
- macOS 10.15 or later
- Xcode command line tools (install with `xcode-select --install`) ( Maybe needed??? idk )


### Editing Layout
1. Click the keyboard icon in the menu bar
2. Select "Edit Mode"
3. Drag keys to reposition them
4. Use the resize handles to change key sizes
5. Add new keys with the "+" button
6. Delete keys with the "-" button
7. Click "Exit Edit Mode" when finished

### Saving Presets
1. Click the keyboard icon in the menu bar
2. Select "Presets" > "Save Preset"
3. Enter a name for your preset
4. Click "Save"

### Loading Presets
1. Click the keyboard icon in the menu bar
2. Select "Presets" > "Load Preset"
3. Choose a saved preset from the list

## Troubleshooting

### Permissions Issues
If the app doesn't detect keystrokes:
1. Go to System Preferences > Security & Privacy > Privacy
2. Check that KeystrokeVisualizer has Accessibility permissions
3. Restart the app

### App Not Responding
If the app becomes unresponsive:
1. Use Cmd+Q to quit
2. Run `make run` to restart

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
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