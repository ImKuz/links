import SharedHelpers
import Foundation
import Constants
import Database
import ComposableArchitecture
import ToolKit

final class SettingsEnvImpl: SettingsEnv {

    private let settings: SettingsHelper
    private let userDefaults: UserDefaults
    private let databaseService: DatabaseService

    init(
        settings: SettingsHelper,
        userDefaults: UserDefaults,
        databaseService: DatabaseService
    ) {
        self.settings = settings
        self.userDefaults = userDefaults
        self.databaseService = databaseService
    }

    func setTabTag(_ value: String) {
        settings.tabTag = value
    }

    func setLinkTapBehaviour(_ value: String) {
        settings.linkTapBehaviour = value
    }

    func discardDefaults() {
        userDefaults.set(nil, forKey: UserDefaultsKeys.lastConnectedHost)
        userDefaults.set(nil, forKey: UserDefaultsKeys.lastConnectedPort)
        userDefaults.set(nil, forKey: UserDefaultsKeys.remoteOption)
    }

    func restoreDefaultSettings() {
        settings.setDefault()
    }

    func eraseAll() -> Effect<Void, AppError> {
        databaseService
            .deleteAll(type: Database.CatalogItem.self)
            .mapError { _ in AppError.businessLogic("Unable to delete items")}
            .eraseToEffect()
    }
}
