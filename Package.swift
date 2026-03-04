// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DebounceKit",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .tvOS(.v17), .visionOS(.v1)],
    products: [
        .library(
            name: "DebounceKit",
            targets: ["DebounceKit"]
        ),
        .library(
            name: "DebounceKitUI",
            targets: ["DebounceKitUI"]
        ),
    ],
    targets: [
        .target(
            name: "DebounceKit"
        ),
        .target(
            name: "DebounceKitUI",
            dependencies: ["DebounceKit"]
        ),
        .testTarget(
            name: "DebounceKitTests",
            dependencies: ["DebounceKit"]
        ),
    ]
)
