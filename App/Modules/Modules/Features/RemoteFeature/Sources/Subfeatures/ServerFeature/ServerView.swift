import SwiftUI
import ComposableArchitecture

struct ServerView: View {

    let store: Store<ServerState, ServerAction>

    var title: some View = Text("Become Server")
        .font(.system(size: 24, weight: .bold, design: .default))
        .padding(.bottom, 4)
        .padding(.leading, 24)

    var description: some View = Text("You may use another Links instance to browse your local snippet storage")
        .padding(.bottom, 4)
        .padding(.leading, 24)
        .foregroundColor(Color.gray)


    var body: some View {
        WithViewStore(store) { viewStore in
                VStack(alignment: .leading) {
                    Spacer()
                    title
                    description
                    HStack(alignment: .center, spacing: 8) {
                        Text("Port")
                        HStack {
                            TextField(
                                viewStore.defaultPort,
                                text: viewStore.binding(
                                    get: { $0.defaultPort },
                                    send: { .portEdited($0) }
                                )
                            )
                            .multilineTextAlignment(.center)
                            .disabled(viewStore.isStarted)
                        }
                        .frame(width: 100, height: 44)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                    }
                    .padding(.leading, 24)
                    HStack {
                        Spacer()
                        Button(action: { viewStore.send(.actionTap) }) {
                            let systemName = viewStore.action == .start
                                ? "antenna.radiowaves.left.and.right"
                                : "antenna.radiowaves.left.and.right.slash"

                            let text = viewStore.action == .start
                                ? "Start"
                                : "Stop"

                            HStack {
                                Image(systemName: systemName)
                                Text(text)
                            }
                        }
                        .buttonStyle(RemoteButtonStyle(
                            color: viewStore.action == .start ? .accentColor : .red
                        ))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        Spacer()
                    }

                    if viewStore.isStarted {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("Server started at:")
                                Text("\(viewStore.host):\(viewStore.port)")
                                    .font(.system(size: 20, weight: .medium, design: .monospaced))

                            }
                            Spacer()
                        }
                    }

                    Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Image(systemName: "xmark")
                    .onTapGesture { viewStore.send(.closeTap) }
                    .foregroundColor(Color.accentColor)
                    .frame(width: 22, height: 22, alignment: .center)
            )
            .background(Color(.systemGroupedBackground))
        }
    }
}

