// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AsyncButton",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AsyncButton",
            targets: ["AsyncButton"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AsyncButton",
            dependencies: [],
            path: "Sources/AsyncButton",
            resources: []
        )
    ]
)
