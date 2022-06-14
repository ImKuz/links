import Models
import ComposableArchitecture
import SharedInterfaces
import ToolKit
import Combine
import CatalogSource

final class AddItemEnvImpl: AddItemEnv {

    let onFinishSubject = PassthroughSubject<Void, Never>()
    private let catalogSource: CatalogSource

    init(catalogSource: CatalogSource) {
        self.catalogSource = catalogSource
    }

    func validateState(_ state: AddItemState) -> Effect<Bool, Never> {
        Just(Self.validate(state: state)).eraseToEffect()
    }

    func cancel() -> Effect<Void, Never> {
        onFinishSubject.send()
        return .none
    }

    func done(state: AddItemState) -> Effect<Void, AppError> {
        guard let item = Self.map(state: state) else {
            return Fail(
                error: AppError.mapping(description: "Unable to map state into CatalogItem")
            ).eraseToEffect()
        }

        return catalogSource
            .add(item: item)
            .eraseToEffect()
    }

    private static func map(state: AddItemState) -> CatalogItem? {
        let option = state.contentOptions[state.selectedOption]

        switch option {
        case .text:
            return .init(name: state.title, text: state.contentText)
        case .link:
            guard let url = URL(string: state.contentText) else { return nil }

            return .init(name: state.title, link: url)
        }
    }

    private static func validate(state: AddItemState) -> Bool {
        let option = state.contentOptions[state.selectedOption]

        if state.title.isEmpty || state.contentText.isEmpty {
            return false
        }

        if case .link = option {
            return state.contentText.isLink
        }

        return true
    }
}
