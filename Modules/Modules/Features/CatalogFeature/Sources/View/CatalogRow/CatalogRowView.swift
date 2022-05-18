import SwiftUI
import ComposableArchitecture
import ToolKit

struct CatalogRowView: View {

    let store: Store<CatalogItem, CatalogRowAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.name)
                .padding()
                .onDrag { .init(object: viewStore.state) }
        }
    }
}

#if DEBUG
struct CatalogRowView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogRowView(
            store: .init(
                initialState: .init(name: "Test", text: "foo"),
                reducer: catalogRowReducer,
                environment: ()
            )
        )
        .previewLayout(.fixed(width: 300, height: 44))
    }
}
#endif
