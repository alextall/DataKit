// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "DataKit",
            targets: [
                "CoreDataClient",
                "HTTPClient",
            ]
        ),
        .library(
            name: "CoreDataClient",
            targets: [
                "CoreDataClient",
            ]
        ),
        .library(
            name: "HTTPClient",
            targets: [
                "HTTPClient",
            ]
        ),
        .library(
            name: "KeychainClient",
            targets: [
                "KeychainClient",
            ]
        ),
    ],
    targets: [
        .target(
            name: "CoreDataClient",
            path: "Sources/CoreDataClient"
        ),
        .target(
            name: "HTTPClient",
            path: "Sources/HTTPClient"
        ),
        .target(
            name: "KeychainClient",
            path: "Sources/KeychainClient"
        ),
    ]
)
