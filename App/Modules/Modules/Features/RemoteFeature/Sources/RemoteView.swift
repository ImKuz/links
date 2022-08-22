import ComposableArchitecture
import SwiftUI

struct RemoteView: View {

    let store: Store<RemoteState, RemoteAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Spacer(minLength: 24)
                VStack {
                    Spacer()

                    Button(action: { viewStore.send(.connectTap) }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Connect to server")
                        }
                    }
                    .buttonStyle(RemoteButtonStyle())

                    Button(action: { viewStore.send(.hostTap) }) {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Become host")
                        }
                    }
                    .buttonStyle(RemoteButtonStyle())

                    Spacer()

                    Toggle(
                        "Remember choice",
                        isOn: viewStore.binding(
                            get: { $0.isRememberSwitchOn },
                            send: { .toggleSwitch(isOn: $0) }
                        )
                    )
                    .frame(minWidth: 0, maxWidth: 250)
                    .padding()

                }
                Spacer(minLength: 24)
            }
            .navigationTitle("Network")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct RemoteButtonStyle: ButtonStyle {

    private let color: Color

    init(color: Color = .accentColor) {
        self.color = color
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .frame(minWidth: 0, maxWidth: 350)
            .padding()
            .background(color)
            .foregroundColor(Color.white)
            .font(
                .system(
                    size: 17,
                    weight: .medium,
                    design: .default
                )
            )
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
