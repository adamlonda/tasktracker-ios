// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "Storage",
            targets: ["Storage"]
        ),
    ],
    dependencies: [
        .package(name: "Models", path: "../Models"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1")
    ],
    targets: [
        .target(
            name: "Storage",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "Models")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        )
    ]
)
