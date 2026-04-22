// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UpdateAvailableKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "UpdateAvailableKit",
            targets: ["UpdateAvailableKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "UpdateAvailableKit",
            dependencies: []),
        .testTarget(
            name: "UpdateAvailableKitTests",
            dependencies: ["UpdateAvailableKit"]),
    ]
)
