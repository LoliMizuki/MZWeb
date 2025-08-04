// swift-tools-version: 6.1
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
        .package(url: "https://github.com/LoliMizuki/MZSwiftsXCFrk", from: "1.4.4")
    ],

    targets: [
        .target(
            name: "MZWeb",
            dependencies: [
                .product(name: "MZSwifts", package: "MZSwiftsXCFrk")
            ]
        ),
        .testTarget(
            name: "MZWebTests",
            dependencies: ["MZWeb"]
        ),
    ]
)
