// swift-tools-version:5.5

import PackageDescription

let content: [(Product, [Target])] = [
    (
        .library(name: "ToolKit", targets: ["ToolKit"]),
        [
            .target(
                name: "ToolKit",
                path: "Modules/ToolKit/Sources"
            ),
            .testTarget(
                name: "ToolKitTests",
                dependencies: ["ToolKit"],
                path: "Modules/ToolKit/Tests"
            ),
        ]
    ),
    (
        .library(name: "SharedInterfaces", targets: ["SharedInterfaces"]),
        [
            .target(
                name: "SharedInterfaces",
                dependencies: [
                    "ToolKit",
                    "Models",
                    .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                ],
                path: "Modules/SharedInterfaces/Sources"
            ),
        ]
    ),
    (
        .library(name: "Models", targets: ["Models"]),
        [
            .target(
                name: "Models",
                path: "Modules/Models/Sources"
            ),
        ]
    ),
    (
        .library(name: "Database", targets: ["Database"]),
        [
            .target(
                name: "Database",
                dependencies: ["ToolKit"],
                path: "Modules/Database/Sources"
            ),
        ]
    ),
    (
        .library(name: "Contracts", targets: ["Contracts"]),
        [
            .target(
                name: "Contracts",
                dependencies: [
                    .product(name: "GRPC", package: "grpc-swift")
                ],
                path: "Modules/Contracts/Sources"
            ),
        ]
    ),
    (
        .library(name: "IPAddressProvider", targets: ["IPAddressProvider"]),
        [
            .target(
                name: "IPAddressProvider",
                dependencies: ["Swinject"],
                path: "Modules/IPAddressProvider/Sources"
            ),
        ]
    ),
    (
        .library(name: "CatalogServer", targets: ["CatalogServer"]),
        [
            .target(
                name: "CatalogServer",
                dependencies: [
                    "Swinject",
                    "ToolKit",
                    "Models",
                    "Contracts",
                    "IPAddressProvider",
                ],
                path: "Modules/CatalogServer/Sources"
            ),
        ]
    ),
    (
        .library(name: "CatalogClient", targets: ["CatalogClient"]),
        [
            .target(
                name: "CatalogClient",
                dependencies: [
                    "Swinject",
                    "ToolKit",
                    "Models",
                    "Contracts",
                ],
                path: "Modules/CatalogClient/Sources"
            ),
        ]
    ),

    // MARK: - Features

    (
        .library(name: "RootFeature", targets: ["RootFeature"]),
        [
            .target(
                name: "RootFeature",
                dependencies: [
                    "ToolKit",
                    "SharedInterfaces",
                    "Models",
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                    .product(name: "Swinject", package: "Swinject")
                ],
                path: "Modules/Features/RootFeature/Sources"
            ),
            .testTarget(
                name: "RootFeatureTests",
                dependencies: ["RootFeature"],
                path: "Modules/Features/RootFeature/Tests"
            ),
        ]
    ),
    (
        .library(name: "CatalogFeature", targets: ["CatalogFeature"]),
        [
            .target(
                name: "CatalogFeature",
                dependencies: [
                    "ToolKit",
                    "Contracts",
                    "SharedInterfaces",
                    "Database",
                    "Models",
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                    .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                    .product(name: "Swinject", package: "Swinject"),
                ],
                path: "Modules/Features/CatalogFeature/Sources"
            ),
            .testTarget(
                name: "CatalogFeatureTests",
                dependencies: ["CatalogFeature"],
                path: "Modules/Features/CatalogFeature/Tests"
            ),
        ]
    ),
    (
        .library(name: "AddItemFeature", targets: ["AddItemFeature"]),
        [
            .target(
                name: "AddItemFeature",
                dependencies: [
                    "ToolKit",
                    "SharedInterfaces",
                    "Models",
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                    .product(name: "Swinject", package: "Swinject"),
                ],
                path: "Modules/Features/AddItemFeature/Sources"
            ),
        ]
    ),
    (
        .library(name: "RemoteFeature", targets: ["RemoteFeature"]),
        [
            .target(
                name: "RemoteFeature",
                dependencies: [
                    "ToolKit",
                    "SharedInterfaces",
                    "Models",
                    "CatalogServer",
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                    .product(name: "Swinject", package: "Swinject"),
                ],
                path: "Modules/Features/RemoteFeature/Sources"
            )
        ]
    )
]

let package = Package(
    name: "CopyPastaModules",
    platforms: [ .iOS(.v15) ],
    products: content.map { $0.0 },
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            branch: "main"
        ),
        .package(
            url: "https://github.com/grpc/grpc-swift.git",
            from: "1.0.0"
        ),
        .package(
            name: "Swinject",
            url: "https://github.com/Swinject/Swinject",
            from: "2.8.1"
        ),
        .package(
            name: "swift-identified-collections",
            url: "https://github.com/pointfreeco/swift-identified-collections",
            from: "0.3.2"
        ),
    ],
    targets: content.flatMap { $0.1 }
)
