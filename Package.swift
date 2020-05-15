// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Huell",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v9),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Huell",
            targets: ["Huell"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Siesta", url: "https://github.com/bustoutsolutions/siesta", from: "1.5.1")],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Huell",
            dependencies: ["Siesta"]),
        .testTarget(
            name: "HuellTests",
            dependencies: ["Huell"]),
    ]
)
