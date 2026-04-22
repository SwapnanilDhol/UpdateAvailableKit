# UpdateAvailableKit
This is UpdateAvailableKit: a super easy way to check if the installed app has an update available. It is built with simplicity and customisability in mind and comes with pre-written tests.

## Requirements
- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+

## Installation
`UpdateAvailableKit` is available via [Swift Package Manager](https://swift.org/package-manager/). To add `UpdateAvailableKit` simply add this repo's URL to your project's package file.

```
https://github.com/SwapnanilDhol/UpdateAvailableKit
```

## Usage

### Quick Start — AppDelegate
For the simplest integration, call `start()` in your AppDelegate:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UpdateAvailableManager.shared.start()
    return true
}
```

### Configuration
Customize `UpdateAvailableKit` by creating a configuration before calling `start()`:

```swift
let config = UpdateAvailableConfiguration(
    bundleID: "com.example.app",
    cacheDuration: 7200
)
UpdateAvailableManager.shared.configure(with: config)
UpdateAvailableManager.shared.start()
```

### Observe Results
Subscribe to the `result` published property to react to update availability:

```swift
// SwiftUI
@ObservedObject var manager = UpdateAvailableManager.shared

var body: some View {
    Group {
        switch manager.result {
        case .updateAvailable(let newVersion):
            Text("Update available: \(newVersion)")
        case .noUpdatesAvailable:
            Text("No updates available")
        }
    }
}
```

```swift
// Combine
UpdateAvailableManager.shared.$result
    .sink { result in
        switch result {
        case .updateAvailable(let newVersion):
            print("Update available: \(newVersion)")
        case .noUpdatesAvailable:
            print("No updates available")
        }
    }
    .store(in: &cancellables)
```

### UpdateAvailableResult
```swift
public enum UpdateAvailableResult: Equatable {
    case updateAvailable(newVersion: String)
    case noUpdatesAvailable
}
```

## Caching
Responses are cached in `UserDefaults` for 3600 seconds by default. Use `UpdateAvailableConfiguration.cacheDuration` to customize.

## Like the framework?
If you like `UpdateAvailableKit` please consider buying me a coffee 🥰

<a href="https://www.buymeacoffee.com/swapnanildhol"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=swapnanildhol&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00"></a>

## Contributions
Contributions are always welcome. Please follow the following convention if you're contributing:
* NameOfFile: Changes Made
* One commit per feature
* For issue fixes: #IssueNumber NameOfFile: ChangesMade

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/SwapnanilDhol/UpdateAvailableKit/blob/main/LICENSE.md) file for details
