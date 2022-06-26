import Foundation
import Constants
import Models
import Combine

public protocol SettingsHelper: AnyObject {

    var tabTag: String { get set }
    var linkTapBehaviour: String { get set }
    var changesPublisher: AnyPublisher<Void, Never> { get }

    func setDefault()
}

public final class SettingsHelperImpl: SettingsHelper {

    private let changesSubject = PassthroughSubject<Void, Never>()
    private let userDefaults: UserDefaults

    private let defaultTabTag: String
    private let defaultLinkTapBehaviour: String

    private var shouldNotifyAboutChanges = true

    public var tabTag: String {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.Settings.defaultTabTag) as? String
                ?? defaultTabTag
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.Settings.defaultTabTag)
            notify()
        }
    }

    public var linkTapBehaviour: String {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.Settings.linkTapBehaviour) as? String
                ?? defaultLinkTapBehaviour
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.Settings.linkTapBehaviour)
            notify()
        }
    }

    public var changesPublisher: AnyPublisher<Void, Never> {
        changesSubject
            .share()
            .eraseToAnyPublisher()
    }

    init(
        userDefaults: UserDefaults,
        defaultTabTag: String,
        defaultLinkTapBehaviour: String
    ) {
        self.userDefaults = userDefaults
        self.defaultTabTag = defaultTabTag
        self.defaultLinkTapBehaviour = defaultLinkTapBehaviour
    }

    public func setDefault() {
        shouldNotifyAboutChanges = false
        tabTag = defaultTabTag
        linkTapBehaviour = linkTapBehaviour
        shouldNotifyAboutChanges = true
        notify()
    }

    private func notify() {
        guard shouldNotifyAboutChanges else { return }
        changesSubject.send()
    }
}
