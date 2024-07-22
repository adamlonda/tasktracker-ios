// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Models",
            targets: ["Models", "ModelsMocks"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.2"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
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
