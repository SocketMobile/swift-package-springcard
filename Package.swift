// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpringCard",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "SpringCard",
            targets: ["SpringCard"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.3"))
    ],
    targets: [
        .target(
            name: "SpringCard",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            linkerSettings: [
                .linkedFramework("CoreBluetooth"),
                .linkedFramework("Foundation")
            ])
    ],
    swiftLanguageVersions: [.v5]
)
