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
            name: "CodableFileClient",
            targets: [
                "CodableFileClient",
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
            name: "CodableFileClient",
            path: "Sources/CodableFileClient"
        ),
    ]
)
