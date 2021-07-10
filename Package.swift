// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataKit",
    platforms: [
        .macOS("12"),
//        .iOS(.v15),
//        .tvOS(.v15),
//        .watchOS(.v8),
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
