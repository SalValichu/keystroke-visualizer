# TODO: Fix Keystroke Visualizer Issues

## Current Issues
- Launches with hardcoded keys in overlay, but editor mode doesn't allow editing them properly.
- Duplicate keys if custom items match hardcoded.
- Save doesn't persist properly.
- Poor UX: black background, high window level, interference.

## Updated Plan
1. **Keep hardcoded keys in OverlayView** for initial display.
2. **In editor mode**: Show hardcoded + custom items, allow editing all.
3. **Save functionality**: Save all items to temporary folder on save button.
4. **Load on editor close**: Pull saved items back to display.
5. **Remove temp folder on quit**.
6. **Presets separate**: Keep preset functionality distinct.
7. **UX improvements**: Transparent overlay, lower window level, better separation, feedback.

## Implementation Steps
- [x] Modify OverlayView.swift: Removed hardcoded keys, show all items from editorState.
- [x] Update EditorState.swift: Load from temp session, save to temp folder, remove on quit.
- [x] Modify AppDelegate.swift: Lower window level, remove temp folder on quit, fix duplicates by hiding overlay in editor mode.
- [x] Update EditorCanvasView.swift: Added save feedback.
- [x] Add CPS counters for LMB/RMB.
- [x] Improve UX: Add tooltips, better error handling.
- [ ] Test: Launch with hardcoded, edit in editor, save, close, verify persistence.
- [x] Make mouse buttons light up when clicked like keys do.
  - [x] Add pressedMouseButtons Set to InputManager.
  - [x] Update event callback to track pressed mouse buttons.
  - [x] Update OverlayView isPressed to handle LMB/RMB tokens.
- [x] Fix CPS calculation to show actual clicks per second.
  - [x] Add click timestamps arrays and timer to calculate real CPS.
