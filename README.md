# PhotoHider

An iOS app (SwiftUI, iOS 16+) for hiding photos in bulk using Apple's official Photos API.

<a href="https://apps.apple.com/br/app/hide-photos-by-date/id6780264707">
  <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/pt-br?size=250x83" alt="Baixar Hide Photos by Date na App Store" height="50">
</a>

## Features

1. Requests `readWrite` access to the photo library.
2. Counts visible photos (`hidden == NO`).
3. Marks visible photos as hidden (`isHidden = true`) in batches.

## Build

1. Run `xcodegen generate` inside the folder.
2. Open `PhotoManager.xcodeproj` in Xcode.
