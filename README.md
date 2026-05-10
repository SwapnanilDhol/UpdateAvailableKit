# UpdateAvailableKit

`UpdateAvailableKit` is a lightweight package for checking whether an installed app has an update available and, when desired, showing an update banner UI.

## Requirements
- iOS 15.0+
- tvOS 15.0+
- watchOS 8.0+

## Installation
Add `UpdateAvailableKit` with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/SwapnanilDhol/UpdateAvailableKit", from: "1.0.0")
]
```

## Usage

### Quick Start

```swift
import UpdateAvailableKit

UpdateAvailableManager.shared.start()
```

### Configuration

```swift
let configuration = UpdateAvailableConfiguration(
    bundleID: "com.example.app",
    cacheDuration: 7200
)

UpdateAvailableManager.shared.configure(with: configuration)
UpdateAvailableManager.shared.start()
```

### Observe Results

```swift
import SwiftUI
import UpdateAvailableKit

struct ContentView: View {
    @ObservedObject private var updateManager = UpdateAvailableManager.shared

    var body: some View {
        Group {
            switch updateManager.result {
            case .updateAvailable(let newVersion):
                Text("Update available: \(newVersion)")
            case .noUpdatesAvailable:
                Text("No updates available")
            }
        }
    }
}
```

### SwiftUI Banner

```swift
import SwiftUI
import UpdateAvailableKit

struct ContentView: View {
    @ObservedObject private var updateManager = UpdateAvailableManager.shared

    var body: some View {
        VStack {
            Spacer()

            UpdateAvailableBannerView(
                result: updateManager.result,
                appStoreID: "123456789"
            )
        }
        .onAppear {
            UpdateAvailableManager.shared.start()
        }
    }
}
```

Or provide a version string directly:

```swift
UpdateAvailableBannerView(
    newVersion: "2.3.0",
    theme: .default,
    appStoreID: "123456789"
)
```

The banner UI is available on platforms that support both `SwiftUI` and `UIKit`.

### Core Types

```swift
public enum UpdateAvailableResult: Equatable {
    case updateAvailable(newVersion: String)
    case noUpdatesAvailable
}
```

## Caching
Responses are cached in `UserDefaults` for 3600 seconds by default. Use `UpdateAvailableConfiguration.cacheDuration` to customize.

## License
This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md).
