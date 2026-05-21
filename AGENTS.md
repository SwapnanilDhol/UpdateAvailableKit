# AGENTS.md — UpdateAvailableKit

## Project Overview

UpdateAvailableKit is a lightweight SPM library that checks whether an installed iOS/tvOS/watchOS app has an update available on the App Store by querying the iTunes Search API (`itunes.apple.com/lookup`), comparing semantic versions, and caching results in `UserDefaults`. It also provides an optional SwiftUI banner to prompt users to update.

- **Language:** Swift 5.9+
- **Platforms:** iOS 15+, tvOS 15+, watchOS 8+
- **Framework:** Combine + SwiftUI (UI optional, conditionally compiled)
- **Dependencies:** None (zero external deps)
- **Test Framework:** Swift Testing (`@Test` / `#expect`)

## Quick Start

```swift
// Package.swift
.package(url: "https://github.com/SwapnanilDhol/UpdateAvailableKit", from: "2.0.0")

// App entry point
import UpdateAvailableKit
UpdateAvailableManager.shared.start()
```

## Public API

```swift
// Configure before start (optional — defaults: bundleID = nil, cacheDuration = 3600s)
UpdateAvailableManager.shared.configure(with: .init(
    bundleID: "com.example.app",
    cacheDuration: 7200
))

// Observe result in SwiftUI
@ObservedObject private var manager = UpdateAvailableManager.shared

switch manager.result {
case .updateAvailable(let newVersion): // new version on App Store
case .noUpdatesAvailable:              // up to date or error
}

// Show built-in banner (requires SwiftUI + UIKit)
UpdateAvailableBannerView(
    result: manager.result,
    appStoreID: "123456789" // numeric App Store ID
)

// Custom banner theme
UpdateAvailableBannerTheme(
    backgroundColor: .orange.opacity(0.15),
    titleColor: .orange,
    iconName: "star.fill",
    buttonTitle: "Get Update",
    buttonColor: .orange
)
```

## Build & Test Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Build with Xcode (generates workspace from Package.swift)
open Package.swift

# Clean build artifacts
swift package clean
```

## Architecture

```
Sources/UpdateAvailableKit/
├── UpdateAvailableManager.swift   # Singleton, ObservableObject, core logic
├── Models/
│   ├── UpdateAvailableResult.swift     # Public result enum
│   ├── ITunesLookupResponse.swift      # iTunes API response model
│   ├── ITunesLookupResult.swift        # iTunes API result entry model
│   └── LookupCachableResponse.swift    # Cache wrapper (response + expiry)
└── UI/
    ├── UpdateAvailableBannerView.swift # SwiftUI banner (UIKit-aware)
    └── UpdateAvailableBannerTheme.swift # Configurable theme
```

### Key Design Patterns

- **Singleton + ObservableObject:** `UpdateAvailableManager.shared` publishes a `@Published result` for SwiftUI integration.
- **Conditional compilation:** UI components are gated on `canImport(SwiftUI) && canImport(UIKit)` so the core logic is available on all platforms.
- **Cache-aside:** Check `UserDefaults` cache first → fetch from network → cache the response with a TTL.
- **Semantic version comparison:** Splits version strings by `.`, pads with zeros, compares component-wise.

## Code Conventions

- Public API surface is minimal: `UpdateAvailableManager`, `UpdateAvailableConfiguration`, `UpdateAvailableResult`, `UpdateAvailableBannerView`, `UpdateAvailableBannerTheme`
- Internal types are module-private by default (SPM default access level)
- Use `async/await` for networking, `@MainActor` where UI updates occur
- Use Swift Testing (`import Testing`) for tests, not XCTest
- Platform guards: `#if canImport(SwiftUI)` for UI code, `#if DEBUG` for previews
- File headers reference LICENSE.md (MIT)

## Publishing

- Bump the version in the git tag (currently `2.0.0`)
- The SPM package URL is `https://github.com/SwapnanilDhol/UpdateAvailableKit`
- Ensure README version references match the tag
