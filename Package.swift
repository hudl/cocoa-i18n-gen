// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CocoaLoco",
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    ],
    targets: [
        .target(name: "CocoaLoco", dependencies: ["CocoaLocoCore"]),
        .target(name: "CocoaLocoCore", dependencies: ["Commander"]),
        .testTarget(name: "CocoaLocoTests", dependencies: ["CocoaLocoCore"]),
    ]
)
