// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Services",
            targets: ["Services"]
        )
    ],
    dependencies: [
        .package(path: "../Client"),
        .package(path: "../UI"),
        .package(path: "../Anima"),
        .package(path: "../SGToolTip"),
        .package(path: "../SgMaps")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Services",
            dependencies: [
                .product(name: "Client", package: "Client"),
                .product(name: "UI", package: "UI"),
                .product(name: "Anima", package: "Anima"),
                .product(name: "SGToolTip", package: "SGToolTip"),
                .product(name: "SgMaps", package: "SgMaps")
            ]
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["Services"]
        )
    ]
)
