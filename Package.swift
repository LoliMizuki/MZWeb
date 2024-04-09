// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MZWeb",
    
    platforms: [.iOS(.v16)],
    
    products: [
        .library(
            name: "MZWeb",
            targets: ["MZWeb"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/LoliMizuki/MZSwiftsXCFrk", branch: "main"),
    ],

    targets: [
        .target(
            name: "MZWeb"
        ),
        .testTarget(
            name: "MZWebTests",
            dependencies: ["MZWeb"]
        ),
    ]
)
