import SwiftUI
import SharedEnv
import ComposableArchitecture
import SharedInterfaces

public struct CatalogView:
    View,
    CatalogViewHolder,
    DropDelegate
{

    public var view: AnyView { .init(self) }

    let store: Store<CatalogState, CatalogAction>
    var viewStore: ViewStore<CatalogState, CatalogAction>

    @State var currentDragged: CatalogItem?

    init(store: Store<CatalogState, CatalogAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: { $0 }))
    }

    public var body: some View {
        List {
            ForEachStore(
                store.scope(
                    state: \.items,
                    action: CatalogAction.rowAction
                ),
                content: CatalogRowView.init
            )
            .onDelete { viewStore.send(.deleteRow($0)) }
            .onInsert(of: [CatalogItem.typeIdentifier]) { index, itemProviders in
                viewStore.send(.prepareDropTarget(index: index, item: itemProviders.first))
            }
        }
        .onTapGesture { viewStore.send(.test) }
        .onAppear { viewStore.send(.onAppear) }
        #if !os(macOS)
        .navigationBarHidden(true)
        #endif
    }
}

#if DEBUG
struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogFeatureAssembly.previewMock()
    }
}
#endif
