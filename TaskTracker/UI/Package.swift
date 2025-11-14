// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]
        ),
    ],
    dependencies: [
        .package(name: "Reducers", path: "../Reducers"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                .product(name: "Reducers", package: "Reducers")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        )
    ]
)
