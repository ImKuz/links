import SwiftUI
import ComposableArchitecture

struct TextEditorView: View {

    let store: Store<TextEditorState, TextEditorAction>

    init(store: Store<TextEditorState, TextEditorAction>) {
        self.store = store
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    Button("Save") { viewStore.send(.finish) }
                        .padding(.trailing)
                        .padding(.top)
                }
                Spacer(minLength: 16)
                HStack {
                    Toggle(
                        "Use Base64 encoding",
                        isOn: viewStore.binding(
                            get: { $0.isBase64EncodingOn },
                            send: { TextEditorAction.setBase64EncodingEnabled($0) }
                        )
                    )
                    .padding(.horizontal)
                }
                TextEditor(
                    text: viewStore.binding(
                        get: { $0.text },
                        send: { .updateText($0) }
                    )
                )
                .font(.system(size: 15, weight: .regular, design: .monospaced))
                .foregroundColor(.white)
                .background(Color(.darkGray))
                .cornerRadius(8)
                .padding()
            }
        }
    }
}
