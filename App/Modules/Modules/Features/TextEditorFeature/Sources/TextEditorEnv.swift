import Combine

final class TextEditorEnvImpl: TextEditorEnv {

    let onFinishSubject = PassthroughSubject<String, Never>()

    func finish(with state: TextEditorState) {
        onFinishSubject.send(state.text)
    }
}
