import UIKit
import SwiftUI
import ComposableArchitecture
import LinkItemActions
import UIComponents

struct EditLinkView: View {

    private enum Labels {
        static let delete = Label("Delete", systemImage: "trash")
        static let addParam = Label("Add param", systemImage: "plus.circle")
        static let copyLink = Label("Copy Link", systemImage: "doc.on.doc")
    }

    private enum Images {
        static let openLink = Image(systemName: "play.fill")
        static let actionsMenu = Image(systemName: "ellipsis")
        static let expandValue = Image(systemName: "arrow.up.backward.and.arrow.down.forward")
    }

    // MARK: - Properties
    let store: Store<EditLinkState, EditLinkAction>
    var actionsProvider: ((String) async -> [LinkItemAction.WithData])?
    var menuViewControllerProvider: (() -> MenuViewController?)?

    // MARK: - View

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                header(viewStore: viewStore)
                formView(viewStore: viewStore)
            }
            .padding(.top, 16)
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
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

                Button(action: { viewStore.send(.open) }) {
                    Images.openLink
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
                        .frame(width: 44, height: 44, alignment: .center)
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
        ActionsButtonViewRepresentable(onTap: { button in
            guard let menuViewController = menuViewControllerProvider?() else { return }

            menuViewController.present(
                onto: button,
                initialActions: [
                    .init(id: "loader", name: "Loading", iconName: "rays")
                ]
            )

            menuViewController.onActionTap = { [weak menuViewController] action in
                guard let action = LinkItemAction(rawValue: action.id) else { return }
                let actionWithData = action.withData(.init(itemId: viewStore.itemId))
                menuViewController?.dismiss()
                viewStore.send(.onLinkItemAction(action: actionWithData))
            }

            Task {
                guard let actions = await actionsProvider?(viewStore.itemId) else { return }

                let menuActions = actions.map {
                    MenuAction(
                        id: $0.action.rawValue,
                        name: $0.data.label?.title ?? "",
                        iconName: $0.data.label?.iconName ?? "",
                        isDestructive: $0.data.isDestructive
                    )
                }

                await menuViewController.updateMenuActions(menuActions)
            }
        })
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
            .font(.system(size: 15, weight: .regular, design: .monospaced))
            .textContentType(.URL)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .keyboardType(.URL)
    }
}
