import SwiftUI
import ComposableArchitecture

struct ConnectFormView: View {

    let store: Store<ConnectFormState, ConnectFormAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    HStack {
                        Button("Cancel") { viewStore.send(.cancelTap) }
                            .buttonStyle(.borderless)
                            .controlSize(.regular)
                            .tint(.accentColor)
                        Spacer()
                        Button("Done") { viewStore.send(.doneTap) }
                            .buttonStyle(.borderless)
                            .controlSize(.regular)
                            .tint(.accentColor)
                    }

                    Text("Connection Details")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 24)

                Form {
                    Section("Connection") {
                        TextField("Host", text: viewStore.binding(\.$host))
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        TextField("Port", text: viewStore.binding(\.$port))
                            .keyboardType(.numberPad)
                    }
                }
            }
            .padding(.top, 16)
            .background(Color(.secondarySystemBackground))
        }
    }
}
