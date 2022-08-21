import ComposableArchitecture
import FeatureSupport
import Swinject
import SwiftUI

public struct TextEditorFeatureAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        let factory: (Resolver, String) -> TextEditorFeatureInterface = { _, text in
            let enviroment = TextEditorEnvImpl()

            let store = Store<TextEditorState, TextEditorAction>(
                initialState: TextEditorState(text: text),
                reducer: textEditorReducer,
                environment: enviroment
            )

            let view = TextEditorView(store: store)

            return TextEditorFeatureInterface(
                view: AnyView(view),
                onFinishPublisher: enviroment.onFinishSubject.eraseToAnyPublisher()
            )
        }

        container.register(TextEditorFeatureInterface.self, factory: factory)
    }
}
