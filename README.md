# PhotoHider

An iOS app (SwiftUI, iOS 16+) for hiding photos in bulk using Apple's official Photos API.

## Features

1. Requests `readWrite` access to the photo library.
2. Counts visible photos (`hidden == NO`).
3. Marks visible photos as hidden (`isHidden = true`) in batches.

## Build

1. Run `xcodegen generate` inside the folder.
2. Open `PhotoManager.xcodeproj` in Xcode.
