# UpdateAvailableKit
This is UpdateAvailableKit: a super easy way to check if the installed app has an update available. It is built with simplicity and customisability in mind and comes with pre-written tests.

## Installation 
`UpdateAvailableKit` is available via [Swift Package Manager](https://swift.org/package-manager/). To add `UpdateAvailableKit` simply add this repo’s URL to your project’s package file. You can choose to use one of the stable releases (tagged) or you can point your package file to the main branch of this project. Although, I would not merge broken code into the `main` branch, if you prefer stability, it’s recommended to use a tagged version.

```
https://github.com/SwapnanilDhol/UpdateAvailableKit
```

## Usage
`UpdateAvailableKit` operates using a singleton class named `UpdateAvailableManager`. This class contains two publicly exposed methods. The important driver is this method:

```swift
public func checkForVersionUpdate(
    with bundleID: String = Bundle.main.bundleIdentifier,
    currentVersion: String = Bundle.main.releaseVersionNumber,
    useCache: Bool = true,
    completion: @escaping((Result<UpdateAvailableResult, Error>) -> Void)
)
```

`checkForVersionUpdate` is self describing. It checks the current version that’s installed on the device and compares it to the version that’s live on the AppStore. It returns a Swift Result where Success is `UpdateAvailableResult` and failure is a generic `Error` for now.

The function accepts a few parameters. Most of them have a default value attached to them but can be overridden when necessary.
* `bundleID`: Pass a Bundle Identifier here. It defaults to your target’s `Bundle.main.bundleIdentifer` value.
* `currentVersion`: Pass the current version of your app in a `String` format (XX.XX.XX). This, again, defaults to the current version of the app using values from `Bundle.main`.
* `useCache`: Flag to decide if the completion handler returns values from a cached response or a newly fetched result from iTunes. More about Caching in `UpdateAvailableKit` towards the end of this file.

Use it in your projects like this

```swift
UpdateAvailableManager.shared.checkForVersionUpdate { result in
    switch result {
    case .success(let result):
        switch result {
        case .updateAvailable(let newVersion):
            print("Update Available. New Verison is \(newVersion)")
        case .noUpdatesAvailable:
            print("No updates available")
        }
    case .failure(let error):
        print("Error did Occur. Error was \(error)")
    }
}
```

### UpdateAvailableResult
`UpdateAvailableResult` is an enum conforming to `Equtable` with two cases: 

```swift
case updateAvailable(newVersion: String)
```
This case will be returned by the `checkForVersionUpdate` method’s completion handler when there’s a new version available. The associated value is the latest AppStore version in `String` type.

```swift
case noUpdatesAvailable
```
This case will be returned when the current installed version is equal to or greater than the AppStore version.

## Async Alternative
`UpdateAvailableKit` support Swift's new [concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) features.
If you’re using iOS 15 and above, you can choose to use the `async` `await` alternative. Thanks to [Rudrank Riyam](https://github.com/rudrankriyam) for this contribution.

```swift
switch try await UpdateAvailableManager.shared.checkForVersionUpdate() {
case .updateAvailable(let newVersion):
    print("New Version is available. \(newVersion)")
case .noUpdatesAvailable:
    print("No updates available")
}
```

## Caching
To fetch the current AppStore version, `UpdateAvailableKit` performs a GET request to the ITunesLookup end point. The URL is
`https://itunes.apple.com/lookup?bundleID=yourBundleID`.\
The response is then cached for 3600 seconds so as to not make repeated calls to the API and to trigger the completion super fast.🚀 The response is encoded and stored in `UserDefaults`. No external cache solution is used. In the future, I’d like to move it to a solution based on SwiftCache.

## Like the framework?
If you like `UpdateAvailableKit` please consider buying me a coffee 🥰

<a href="https://www.buymeacoffee.com/swapnanildhol"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=swapnanildhol&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00"></a>

## Contributions 
Contributions are always welcome. Please follow the following convention if you’re contributing:
* NameOfFile: Changes Made 
* One commit per feature 
* For issue fixes: #IssueNumber NameOfFile: ChangesMade

## License
This project is licensed under the MIT License - see the  [LICENSE](https://github.com/SwapnanilDhol/UpdateAvailableKit/blob/main/LICENSE.md)  file for details
