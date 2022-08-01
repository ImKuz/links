import Models
import ComposableArchitecture
import SharedInterfaces
import ToolKit
import Combine
import CatalogSource
import UIKit

final class EditLinkEnvImpl: EditLinkEnv {

    let onFinishSubject = PassthroughSubject<Void, Never>()
    private let catalogSource: CatalogSource

    init(catalogSource: CatalogSource) {
        self.catalogSource = catalogSource
    }

    func validateState(_ state: EditLinkState) -> Effect<Set<EditLinkState.ValidateableField>, Never> {
        var invalidFields = Set<EditLinkState.ValidateableField>()

        if state.name.isEmpty {
            invalidFields.insert(.name)
        }

        if state.urlComponents?.url == nil {
            invalidFields.insert(.url)
        }

        state.urlComponents?.queryItems?.enumerated().forEach { index, item in
            if item.name.isEmpty {
                invalidFields.insert(.key(index: index))
            }

            if item.value == nil || item.value?.isEmpty == true {
                invalidFields.insert(.value(index: index))
            }
        }

        return Effect(value: invalidFields)
    }

    func followLink(state: EditLinkState) -> Effect<Void, AppError> {
        if let url = state.urlComponents?.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return Effect(value: ())
        } else {
            return Effect(error: .businessLogic("URL is inavlid"))
        }
    }

    func expandQueryItemValue(value: String) -> Effect<String, Never> {
        return .none
    }

    func done(state: EditLinkState) -> Effect<Void, AppError> {
        guard let item = Self.map(state: state) else {
            return Fail(error: AppError.mapping(description: "Unable to map state into CatalogItem")).eraseToEffect()
        }

        return catalogSource
            .add(item: item)
            .eraseToEffect()
    }

    private static func map(state: EditLinkState) -> CatalogItem? {
        nil
    }
}
