// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-suduko-engine",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-suduko-engine",
            targets: ["swift-suduko-engine"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-suduko-engine"),
        .testTarget(
            name: "swift-suduko-engineTests",
            dependencies: ["swift-suduko-engine"]
        ),
    ]
)
