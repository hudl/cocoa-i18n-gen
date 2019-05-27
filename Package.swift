// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cocoa-i18n",
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    ],
    targets: [
        .target(name: "cocoa-i18n", dependencies: ["Commander"]),
        .testTarget(name: "cocoa-i18nTests", dependencies: ["cocoa-i18n"]),
    ]
)
