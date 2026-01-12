// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BabciaTobiasz",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "BabciaTobiasz",
            targets: ["BabciaTobiasz"]),
    ],
    targets: [
        .target(
            name: "BabciaTobiasz",
            dependencies: [],
            path: "BabciaTobiasz",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "BabciaTobiaszTests",
            dependencies: ["BabciaTobiasz"],
            path: "Tests/BabciaTobiaszTests"
        )
    ]
)
