APP_NAME = KeystrokeVisualizer
SWIFT_FILES = main.swift AppDelegate.swift InputManager.swift LayoutManager.swift OverlayWindow.swift OverlayView.swift FPSMonitor.swift EditorState.swift KeyCodes.swift EditorCanvasView.swift App/ContentView.swift
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app

$(APP_NAME): $(SWIFT_FILES)
	mkdir -p $(BUILD_DIR)
	xcrun --sdk macosx swiftc $(SWIFT_FILES) -o $(BUILD_DIR)/$(APP_NAME) -framework Cocoa -framework SwiftUI

$(APP_BUNDLE): $(APP_NAME) Info.plist
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/

clean:
	rm -rf $(BUILD_DIR)

run: $(APP_BUNDLE)
	open $(APP_BUNDLE)

# Developer-friendly run: stop any previous instance and run the binary to view logs
.PHONY: dev stop

dev: $(APP_BUNDLE)
	- killall $(APP_NAME) 2>/dev/null || true
	./$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)

stop:
	- killall $(APP_NAME) 2>/dev/null || true

install: $(APP_BUNDLE)
	cp -r $(APP_BUNDLE) /Applications/

.PHONY: clean run install