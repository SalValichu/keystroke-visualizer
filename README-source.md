# Keystroke Visualizer

A clean, minimal keystroke visualizer for macOS that displays your keyboard and mouse inputs on screen. Perfect for screen recordings, tutorials, and presentations.

## Features

- Real-time visualization of keyboard and mouse inputs
- Clean, minimal design (Minecraft-style UI)
- Customizable overlay positioning
- Adjustable display duration
- Works with all keyboard layouts
- Lightweight and unobtrusive

## Building from Source

This is the recommended way to use the app, as it avoids macOS security warnings entirely.

### Prerequisites

- macOS 10.15 or later
- Xcode command line tools (install with `xcode-select --install`)

### Building

```bash
# Clone the repository
git clone https://github.com/yourusername/keystroke-visualizer.git
cd keystroke-visualizer

# Build the app
make

# Run the app
make run

# Or install to Applications folder
make install
```

### Running without Make

If you prefer to build manually:

```bash
swiftc *.swift App/*.swift -o KeystrokeVisualizer -framework Cocoa -framework SwiftUI
./KeystrokeVisualizer
```

## Usage

Once launched, the app runs in the background and displays your keystrokes on screen. The visualizer includes:

- WASD keys in a classic arrangement
- Space bar
- Left and right mouse buttons
- Visual feedback when keys are pressed

To quit the app, click the keyboard icon in the menu bar and select "Quit".

## Customization

You can customize the visualizer by:

1. Clicking the keyboard icon in the menu bar
2. Selecting "Edit Mode"
3. Moving and resizing elements as needed
4. Exiting edit mode when finished

## Accessibility Permissions

This app requires accessibility permissions to monitor keystrokes. You'll be prompted to grant these permissions on first launch.

If you need to manually grant permissions:
1. Go to System Preferences > Security & Privacy > Privacy
2. Select "Accessibility" from the left sidebar
3. Click the lock icon and enter your password
4. Add KeystrokeVisualizer to the list of allowed apps

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.