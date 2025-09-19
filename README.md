# Keystroke Visualizer

A clean, minimal keystroke visualizer for macOS that displays your keyboard and mouse inputs on screen. Perfect for screen recordings, tutorials, and presentations.

![Keystroke Visualizer](screenshot.png)

## Beta Version
This is a beta release. The FPS overlay feature is currently not available.

## Quick Start

To get started with the Keystroke Visualizer, run these commands in your terminal:

```bash
git clone https://github.com/SalValichu/keystroke-visualizer.git
cd keystroke-visualizer
make
make run
```

## Initial Setup

When you first run the application, you will be prompted for two system permissions:

1. **Accessibility Permissions** - Required to monitor keystrokes and mouse events
2. **Screen Recording Permissions** - Required to display the overlay on top of other applications

After granting these permissions, the app will close. Simply run `make run` again to start using the application.

## How to Use

### Basic Operation
Once running, the app displays a visual representation of keyboard and mouse inputs on your screen. The default layout includes:

- WASD keys arranged in a classic gaming layout
- Space bar
- Left and right mouse buttons

When you press any of these keys, they will light up with a visual effect.

### Menu Bar Controls
The app adds a keyboard icon to your menu bar. Click this icon to access the following options:

1. **Edit Mode** - Allows you to customize the layout:
   - Move keys by dragging them
   - Resize keys using the resize handles
   - Add new keys using the "+" button
   - Delete keys using the "-" button
   - Exit edit mode when finished

2. **Presets** - Save and load custom layouts:
   - Save your current layout as a preset
   - Load a previously saved preset
   - Delete existing presets

3. **Settings** - Customize display options:
   - Fade delay: How long keys stay visible after being pressed
   - Toggle click-through mode
   - Toggle FPS display (beta feature)

4. **Quit** - Close the application

### Default Controls
- **WASD keys**: Move the visual representation
- **Space bar**: Shows when space is pressed
- **Left mouse button**: Shows when left mouse button is clicked
- **Right mouse button**: Shows when right mouse button is clicked

## Building from Source

### Prerequisites
- macOS 10.15 or later
- Xcode command line tools (install with `xcode-select --install`)

### Build Commands
```bash
# Clone the repository
git clone https://github.com/SalValichu/keystroke-visualizer.git
cd keystroke-visualizer

# Build the app
make

# Run the app
make run

# Install to Applications folder (optional)
make install
```

## Customization

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