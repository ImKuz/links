// swift-tools-version:5.5

import PackageDescription

// MARK: - Public

enum Module: String, CaseIterable, Equatable, Hashable {
    case CatalogClient
    case CatalogServer
    case CatalogSource
    case Constants
    case Contracts
    case Database
    case IPAddressProvider
    case Logger
    case Models
    case ToolKit
    case SharedHelpers
    case LinkItemActions
    case FeatureSupport
    case UIComponents
    // Features
    case EditLinkFeature
    case CatalogFeature
    case RemoteFeature
    case RootFeature
    case SettingsFeature
}

enum Dependency {
    case module(Module)
    case external(Target.Dependency)
}

/// Modules has common dependency list, see below
let dependencyMap: [Module: [Dependency]] = [
    .SharedHelpers: [
        .module(.Models),
    ],
    .CatalogClient: [
        .module(.Models),
        .module(.Contracts),
        .module(.Database),
    ],
    .CatalogServer: [
        .module(.Models),
        .module(.Contracts),
        .module(.IPAddressProvider),
        .external(.product(name: "GRPC", package: "grpc-swift")),
    ],
    .CatalogSource: [
        .module(.Models),
        .module(.Contracts),
        .module(.Database),
        .module(.CatalogClient),
        .external(.product(name: "IdentifiedCollections", package: "swift-identified-collections")),
    ],
    .Contracts: [
        .external(.product(name: "GRPC", package: "grpc-swift")),
    ],
    .Database: [
        .module(.Models),
    ],
    .Logger: [
        .external(.product(name: "Logging", package: "swift-log")),
    ],
    .Models: [
        .external(.product(name: "Collections", package: "swift-collections")),
    ],
    .ToolKit: [
        .external(.product(name: "ComposableArchitecture", package: "swift-composable-architecture")),
    ],
    .LinkItemActions: [
        .module(.Models),
        .module(.CatalogSource),
        .module(.FeatureSupport),
    ],
    .FeatureSupport: [
        .module(.Models),
        .module(.CatalogSource),
    ],
    // Features
    .EditLinkFeature: [
        .module(.CatalogSource),
        .module(.LinkItemActions),
    ],
    .CatalogFeature: [
        .module(.LinkItemActions),
        .module(.SharedHelpers),
    ],
    .RemoteFeature: [
        .module(.CatalogServer),
    ],
    .SettingsFeature: [
        .module(.SharedHelpers),
        .module(.Database),
    ],
]

// MARK: Lists

let unitTestCoveredModules: Set<Module> = [
    .CatalogClient,
    .EditLinkFeature
]

let commonModuleDependencies: [Dependency] = [
    .module(.ToolKit),
    .module(.Constants),
    .module(.Logger),
]

let commonFeatureDependencies: [Dependency] = [
    .module(.Models),
    .module(.FeatureSupport),
    .module(.UIComponents),
    .external(.product(name: "ComposableArchitecture", package: "swift-composable-architecture")),
    .external(.product(name: "IdentifiedCollections", package: "swift-identified-collections")),
]

let externalDependecies: [Package.Dependency] = [
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
    .package(
        name: "swift-collections",
        url: "https://github.com/apple/swift-collections",
        from: "1.0.2"
    ),
    .package(
        url: "https://github.com/apple/swift-log.git",
        from: "1.0.0"
    ),
]

// MARK: - Private

let packageContent: [(Product, [Target])] = {
    var modules = Module.allCases.reduce(into: [(Product, [Target])]()) { array, module in
        let moduleName = module.rawValue
        let isFeature = moduleName.hasSuffix("Feature")
        var targetDependencies = [Target.Dependency]()

        var dependenciesToConvert: [Dependency] = [
            .external("Swinject")
        ]

        if !commonModuleDependencies.contains(where: {
            if case let .module(currentModule) = $0 {
                return currentModule == module
            } else {
                return false
            }
        }) {
            dependenciesToConvert.append(contentsOf: commonModuleDependencies)
        }

        if isFeature {
            dependenciesToConvert.append(contentsOf: commonFeatureDependencies)
        }

        if let definedDependencies = dependencyMap[module] {
            dependenciesToConvert.append(contentsOf: definedDependencies)
        }

        dependenciesToConvert.forEach {
            switch $0 {
            case let .external(dependency):
                targetDependencies.append(dependency)
            case let .module(depModule):
                if depModule != module {
                    targetDependencies.append(.init(stringLiteral: depModule.rawValue))
                }
            }
        }

        let product = Product.library(name: moduleName, targets: [moduleName])
        let baseModulePath = "Modules\(isFeature ? "/Features" : "")/\(moduleName)"

        var targets = [
            Target.target(
                name: moduleName,
                dependencies: targetDependencies,
                path:  baseModulePath + "/Sources"
            )
        ]

        if unitTestCoveredModules.contains(module) {
            targets.append(
                Target.testTarget(
                    name: moduleName + "UnitTests",
                    dependencies: targetDependencies + [.init(stringLiteral: moduleName)],
                    path: baseModulePath + "/UnitTests"
                )
            )
        }

        array.append((product, targets))
    }

    // Assembler module

    var assemblerDependencies: [Target.Dependency] = Module.allCases.map {
        .init(stringLiteral: $0.rawValue)
    }

    assemblerDependencies.append(.init(stringLiteral: "Swinject"))

    modules.append(
        (
            .library(name: "AppAssembler", targets: ["AppAssembler"]),
            [
                .target(
                    name: "AppAssembler",
                    dependencies: assemblerDependencies,
                    path: "Modules/AppAssembler/Sources"
                )
            ]
        )
    )

    return modules
}()

let package = Package(
    name: "CopyPastaModules",
    platforms: [ .iOS(.v15) ],
    products: packageContent.map { $0.0 },
    dependencies: externalDependecies,
    targets: packageContent.flatMap { $0.1 }
)
