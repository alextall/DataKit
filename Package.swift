// swift-tools-version:5.3
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
    ]
)
