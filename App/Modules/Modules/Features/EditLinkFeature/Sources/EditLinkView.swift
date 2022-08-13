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
                urlComponentTextField(
                    placeholder: "URL",
                    text: viewStore.binding(
                        get: \.urlString,
                        send: { .changeUrlString($0) }
                    )
                )
            }

            Section(header: Text("Query params")) {
                ForEach(Array(viewStore.queryParams.enumerated()), id: \.offset) { index, queryParam in
                    queryItemField(
                        viewStore: viewStore,
                        queryParam: queryParam,
                        index: index
                    )
                    .swipeActions {
                        Button(
                            action: { viewStore.send(.deleteQueryParam(index: index)) },
                            label: { Labels.delete }
                        )
                        .tint(.red)
                    }
                }
                Button(
                    action: { viewStore.send(.appendQueryParam) },
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
        queryParam: QueryParam,
        index: Int
    ) -> some View {
        HStack {
            urlComponentTextField(
                placeholder: "Key",
                text: viewStore.binding(
                    get: { _ in queryParam.key },
                    send: { .changeQueryParamKey(key: $0, index: index) }
                )
            )
            urlComponentTextField(
                placeholder: "Value",
                text: viewStore.binding(
                    get: { _ in queryParam.value },
                    send: { .changeQueryParamValue(value: $0, index: index) }
                )
            )
            Images.expandValue
                .foregroundColor(.accentColor)
                .onTapGesture {
                    viewStore.send(.expandQueryParamValue(index: index))
                }
        }
    }

    @ViewBuilder
    private func urlComponentTextField(
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        TextField(placeholder, text: text)
            .textContentType(.URL)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .keyboardType(.URL)
    }
}
