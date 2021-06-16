// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataKit",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
    ],
    products: [
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
            name: "FileClient",
            targets: [
                "FileClient",
            ]
        ),
    ],
    targets: [
        .target(name: "CoreDataClient"),
        .target(name: "HTTPClient"),
        .target(name: "FileClient")
    ]
)
