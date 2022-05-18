// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CopyPastaModules",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ToolKit",
            targets: ["ToolKit"]
        ),
        .library(
            name: "SharedInterfaces",
            targets: ["SharedInterfaces"]
        ),
        .library(
            name: "SharedEnv",
            targets: ["SharedEnv"]
        ),
        .library(
            name: "Models",
            targets: ["Models"]
        ),
        .library(
            name: "Database",
            targets: ["Database"]
        ),
        .library(
            name: "Contracts",
            targets: ["Contracts"]
        ),
        .library(
            name: "RootFeature",
            targets: ["RootFeature"]
        ),
        .library(
            name: "CatalogFeature",
            targets: ["CatalogFeature"]
        ),
    ],
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
    targets: [

        // MARK: - Services and Helpers

        .target(
            name: "ToolKit",
            path: "Modules/ToolKit/Sources"
        ),
        .testTarget(
            name: "ToolKitTests",
            dependencies: ["ToolKit"],
            path: "Modules/ToolKit/Tests"
        ),

        .target(
            name: "SharedInterfaces",
            path: "Modules/SharedInterfaces/Sources"
        ),

        .target(
            name: "SharedEnv",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Modules/SharedEnv/Sources"
        ),

        .target(
            name: "Models",
            path: "Modules/Models/Sources"
        ),

        .target(
            name: "Database",
            dependencies: ["ToolKit"],
            path: "Modules/Database/Sources"
        ),

        .target(
            name: "Contracts",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift")
            ],
            path: "Modules/Contracts/Sources"
        ),

        // MARK: - Features

        .target(
            name: "RootFeature",
            dependencies: [
                "ToolKit",
                "SharedEnv",
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

        .target(
            name: "CatalogFeature",
            dependencies: [
                "ToolKit",
                "SharedEnv",
                "Contracts",
                "SharedInterfaces",
                "Database",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Swinject", package: "Swinject")
            ],
            path: "Modules/Features/CatalogFeature/Sources"
        ),
        .testTarget(
            name: "CatalogFeatureTests",
            dependencies: ["CatalogFeature"],
            path: "Modules/Features/CatalogFeature/Tests"
        ),
    ]
)
