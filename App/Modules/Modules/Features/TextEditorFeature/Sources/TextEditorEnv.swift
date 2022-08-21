import Combine

final class TextEditorEnvImpl: TextEditorEnv {

    let onFinishSubject = PassthroughSubject<String, Never>()

    func finish(with text: String) {
        onFinishSubject.send(text)
    }
}
