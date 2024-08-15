// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AeroSpacePackage",
    platforms: [.macOS(.v13)], /* Runtime support for parameterized protocol types is only available in macOS 13.0.0 or newer
                                  And it specifies deploymentTarget for CLI */
    // Products define the executables and libraries a package produces, making them visible to other packages.
    products: [
        .library(name: "AppBundle", targets: ["AppBundle"]),
        .executable(name: "aerospace", targets: ["Cli"]),
        .executable(name: "AeroSpaceApp", targets: ["AeroSpaceApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/BlueSocket", exact: "2.0.4"),
        .package(url: "https://github.com/soffes/HotKey", exact: "0.1.3"),
        .package(url: "https://github.com/LebJe/TOMLKit", exact: "0.5.5"),
        .package(url: "https://github.com/apple/swift-collections", exact: "1.1.0"),
        .package(url: "https://github.com/antlr/antlr4", exact: "4.13.1"),
    ],
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    targets: [
        .target(
            name: "PrivateAPIBridge",
            path: "Sources/PrivateAPIBridge",
            publicHeadersPath: "include"
        ),
        .target(
            name: "Common",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .target(
            name: "ShellParserGenerated",
            dependencies: [
                .product(name: "Antlr4Static", package: "antlr4"),
            ]
        ),
        .target(
            name: "AppBundle",
            dependencies: [
                .target(name: "PrivateAPIBridge"),
                .target(name: "Common"),
                .target(name: "ShellParserGenerated"),
                .product(name: "Antlr4Static", package: "antlr4"),
                .product(name: "Socket", package: "BlueSocket"),
                .product(name: "HotKey", package: "HotKey"),
                .product(name: "TOMLKit", package: "TOMLKit"),
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .executableTarget(
            name: "AeroSpaceApp",
            dependencies: [
                .target(name: "AppBundle"),
            ]
        ),
        .executableTarget(
            name: "Cli",
            dependencies: [
                .target(name: "Common"),
                .product(name: "Socket", package: "BlueSocket"),
            ]
        ),
        .testTarget(
            name: "AppBundleTests",
            dependencies: [
                .target(name: "AppBundle"),
            ]
        ),
    ]
)
