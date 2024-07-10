// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]
        ),
    ],
    dependencies: [
        .package(name: "Reducers", path: "../Reducers"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
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
