import Models
import ComposableArchitecture
import SharedInterfaces
import ToolKit
import Combine
import CatalogSource
import UIKit

final class EditLinkEnvImpl: EditLinkEnv {

    private let catalogSource: CatalogSource
    private let initialItem: LinkItem

    let onFinishSubject = PassthroughSubject<Void, Never>()

    init(catalogSource: CatalogSource, initialItem: LinkItem) {
        self.catalogSource = catalogSource
        self.initialItem = initialItem
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
        // TODO: Implement edit/add of link item
        .none
    }

    private func map(state: EditLinkState) -> LinkItem {
        .init(
            id: initialItem.id,
            name: state.name,
            urlString: state.urlString,
            isFavorite: initialItem.isFavorite
        )
    }
}
