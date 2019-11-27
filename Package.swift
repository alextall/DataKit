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
                "PersistenceClient",
                "PersistenceClient+Decodable",
                "PersistenceClient+Encodable",
                "HTTPClient",
            ]
        ),
        .library(
            name: "PersistenceClient",
            targets: [
                "PersistenceClient",
            ]
        ),
        .library(
            name: "PersistenceClient+Encodable",
            targets: [
                "PersistenceClient",
                "PersistenceClient+Encodable",
            ]
        ),
        .library(
            name: "PersistenceClient+Decodable",
            targets: [
                "PersistenceClient",
                "PersistenceClient+Decodable",
            ]
        ),
        .library(
            name: "PersistenceClient+Codable",
            targets: [
                "PersistenceClient",
                "PersistenceClient+Decodable",
                "PersistenceClient+Encodable",
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
            name: "PersistenceClient",
            path: "Sources/PersistenceClient"
        ),
        .target(
            name: "PersistenceClient+Decodable",
            dependencies: [
                "PersistenceClient",
            ],
            path: "Sources/PersistenceClient+Decodable"
        ),
        .target(
            name: "PersistenceClient+Encodable",
            dependencies: [
                "PersistenceClient",
            ],
            path: "Sources/PersistenceClient+Encodable"
        ),
        .target(
            name: "HTTPClient",
            path: "Sources/HTTPClient"
        ),
    ]
)
