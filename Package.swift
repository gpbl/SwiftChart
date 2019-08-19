// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftChart",
    products: [
        .library(name: "SwiftChart", targets: ["SwiftChart"]),
    ],
    dependencies: [
    ],
    targets: [
        // SwiftChart
        .target(name: "SwiftChart", dependencies: [
        ], path: "Source"),

        // Testing
        .testTarget(name: "SwiftChartTests", dependencies: ["SwiftChart"], path: "SwiftChartTests"),
    ]
)
