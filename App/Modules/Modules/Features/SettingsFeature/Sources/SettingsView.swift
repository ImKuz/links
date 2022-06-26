import SwiftUI
import ComposableArchitecture

struct SettingsView: View {

    let store: Store<SettingsState, SettingsAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Form {
                    Picker(
                        "Default tab",
                        selection: viewStore.binding(\.$selectedTabOption)
                    ) {
                        ForEach(
                            Array(viewStore.tabOptions.map(\.title).enumerated()),
                            id: \.0
                        ) { index, item in
                            Text(item).tag(index)
                        }
                    }.pickerStyle(.inline)

                    Picker(
                        "Tap on link",
                        selection: viewStore.binding(\.$selectedLinkTapBehaviourOption)
                    ) {
                        ForEach(
                            Array(viewStore.linkTapBehaviours.map(\.title).enumerated()),
                            id: \.0
                        ) { index, item in
                            Text(item).tag(index)
                        }
                    }.pickerStyle(.inline)

                    Button(action: { viewStore.send(.restoreDefaultSettings) }) {
                        Text("Restore default settings")
                    }

                    Button(action: { viewStore.send(.discardDefaults) }) {
                        Text("Discard remembered values")
                    }

                    Button(action: { viewStore.send(.eraseAll) }) {
                        Text("Delete all content")
                            .foregroundColor(.red)
                    }
                }
                Text("App version: \(viewStore.appVersion)")
                    .font(.footnote)
            }
            .alert(
                Text("Are you sure?"),
                isPresented: viewStore.binding(\.$showsConfirmAlert),
                actions: {
                    Button("Confirm", role: .destructive, action: { viewStore.send(.eraseAllConfirm) })
                    Button("Cancel", role: .cancel, action: { })
                },
                message: {
                    Text("All snippets will be deleted")
                }
            )
        }
        .background(Color(.secondarySystemBackground))
    }
}
