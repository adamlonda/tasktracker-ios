// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Reducers",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Reducers",
            targets: ["Reducers"]
        ),
    ],
    dependencies: [
        .package(name: "Models", path: "../Models"),
        .package(name: "Storage", path: "../Storage"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
    ],
    targets: [
        .target(
            name: "Reducers",
            dependencies: [
                .product(name: "Models", package: "Models"),
                .product(name: "Storage", package: "Storage")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "ReducersTests",
            dependencies: ["Reducers"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
    ]
)
