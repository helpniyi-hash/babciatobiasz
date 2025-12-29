// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherHabitTracker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "WeatherHabitTracker",
            targets: ["WeatherHabitTracker"]),
    ],
    targets: [
        .executableTarget(
            name: "WeatherHabitTracker",
            dependencies: [],
            path: "WeatherHabitTracker",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "WeatherHabitTrackerTests",
            dependencies: ["WeatherHabitTracker"],
            path: "WeatherHabitTrackerTests"
        ),
        .testTarget(
            name: "WeatherHabitTrackerUITests",
            dependencies: ["WeatherHabitTracker"],
            path: "WeatherHabitTrackerUITests"
        )
    ]
)
