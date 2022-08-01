import UIKit
import SwiftUI
import ComposableArchitecture

struct EditLinkView: View {

    private enum Labels {
        static let delete = Label("Delete", systemImage: "trash")
        static let addParam = Label("Add param", systemImage: "plus.circle")
        static let copyLink = Label("Copy Link", systemImage: "doc.on.doc")
    }

    private enum Images {
        static let followLink = Image(systemName: "play.fill")
        static let actionsMenu = Image(systemName: "ellipsis")
        static let expandValue = Image(systemName: "arrow.up.backward.and.arrow.down.forward")
    }

    // MARK: - Properties
    let store: Store<EditLinkState, EditLinkAction>

    // MARK: - View

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                header(viewStore: viewStore)
                formView(viewStore: viewStore)
            }
            .padding(.top, 16)
            .background(Color(.secondarySystemBackground))
        }
    }

    // MARK: - ViewBuilder

    @ViewBuilder
    private func header(viewStore: EditLinkViewStore) -> some View {
        ZStack {
            HStack {
                Button("Done") { viewStore.send(.done) }
                .buttonStyle(.borderless)
                .controlSize(.regular)
                .tint(.accentColor)
                Spacer()

                Button(action: { viewStore.send(.follow) }) {
                    Images.followLink
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.borderless)
                .tint(.accentColor)
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func formView(viewStore: EditLinkViewStore) -> some View {
        Form {
            Section() {
                HStack {
                    TextField(
                        "Name",
                        text: viewStore.binding(
                            get: \.name,
                            send: { .changeName($0) }
                        )
                    )
                    menu(viewStore: viewStore)
                }
            }

            Section() {
                TextField(
                    "URL",
                    text: viewStore.binding(
                        get: \.urlString,
                        send: { .changeUrl($0) }
                    )
                )
            }

            Section(header: Text("Query params")) {
                ForEach(Array(viewStore.queryItems.enumerated()), id: \.offset) { index, item in
                    queryItemField(
                        viewStore: viewStore,
                        queryItem: item,
                        index: index
                    )
                    .swipeActions {
                        Button(
                            action: { viewStore.send(.deleteQueryItem(index: index)) },
                            label: { Labels.delete }
                        )
                        .tint(.red)
                    }
                }
                Button(
                    action: { viewStore.send(.addQueryItem) },
                    label: { Labels.addParam }
                )
            }
        }
    }

    @ViewBuilder
    private func menu(viewStore: EditLinkViewStore) -> some View {
        Menu(
            content: {
                Button(
                    action: { viewStore.send(.copy) },
                    label: { Labels.copyLink }
                )
                Button(
                    role: .destructive,
                    action: { viewStore.send(.delete) },
                    label: { Labels.delete }
                )
            },
            label: {
                Images.actionsMenu
                    .padding(.all, 8)
                    .tint(.accentColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor)
                            .opacity(0.25)
                    }
            }
        )
    }

    @ViewBuilder
    private func queryItemField(
        viewStore: EditLinkViewStore,
        queryItem: URLQueryItem,
        index: Int
    ) -> some View {
        HStack {
            TextField(
                "Key",
                text: viewStore.binding(
                    get: { _ in queryItem.name },
                    send: { .changeQueryItemName(key: $0, index: index) }
                )
            )
            TextField(
                "Value",
                text: viewStore.binding(
                    get: { _ in queryItem.value ?? "" },
                    send: { .changeQueryItemValue(value: $0, index: index) }
                )
            )
            Images.expandValue
                .foregroundColor(.accentColor)
                .onTapGesture {
                    viewStore.send(.expandQueryItemValue(index: index))
                }
        }
    }
}
