import ComposableArchitecture

struct TextEditorState: Equatable {
    var text: String
    var isBase64EncodingOn = false
}

enum TextEditorAction: Equatable {
    case setBase64EncodingEnabled(Bool)
    case updateText(String)
    case finish
}

protocol TextEditorEnv {
    func finish(with state: TextEditorState)
}

let textEditorReducer = Reducer<TextEditorState, TextEditorAction, TextEditorEnv> { state, action, env in
    switch action {
    case .setBase64EncodingEnabled(let isOn):
        state.isBase64EncodingOn = isOn
    case .updateText(let newText):
        state.text = newText
    case .finish:
        env.finish(with: state)
    }

    return .none
}
