import ComposableArchitecture

struct TextEditorState: Equatable {
    var text: String
}

enum TextEditorAction: Equatable {
    case updateText(String)
    case finish
}

protocol TextEditorEnv {
    func finish(with state: TextEditorState)
}

let textEditorReducer = Reducer<TextEditorState, TextEditorAction, TextEditorEnv> { state, action, env in
    switch action {
    case .updateText(let newText):
        state.text = newText
    case .finish:
        env.finish(with: state)
    }

    return .none
}
