import Swinject
import Database
import IPAddressProvider
import CatalogServer
import CatalogClient
import CatalogSource
import Logger
import SharedHelpers
import LinkItemActionsService
import FeatureSupport

import RootFeature
import CatalogFeature
import EditLinkFeature
import RemoteFeature
import SettingsFeature

public enum DIAssemblerFactory {

    public static func make(container: Container) -> Assembler {
        let assmbler = Assembler(container: container)
        applyAssemblies(to: assmbler)
        return assmbler
    }

    private static func applyAssemblies(to assembler: Assembler) {
        assembler.apply(assemblies: [

            // MARK: - Services

            ServicesAssembly(),
            LoggerAssembly(),
            SharedHelpersAssembly(),
            DatabaseServiceAssembly(),
            IPAddressProviderAssembly(),
            CatalogServerAssembly(),
            CatalogClientAssembly(),
            CatalogSourceAssembly(),
            FeatureResolverAssembly(),
            LinkItemActionsServiceAssembly(),

            // MARK: - Features

            RootFeatureAssembly(),
            CatalogFeatureAssembly(),
            EditLinkFeatureAssembly(),
            RemoteFeatureAssembly(),
            SettingsFeatureAssembly(),
        ])
    }
}
