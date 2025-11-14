// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "Models",
            targets: ["Models", "ModelsMocks"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1")
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Tagged", package: "swift-tagged")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
        .target(
            name: "ModelsMocks",
            dependencies: ["Models"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        )
    ]
)
