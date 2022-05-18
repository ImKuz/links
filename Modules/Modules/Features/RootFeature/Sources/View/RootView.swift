#if os(iOS)

import SwiftUI
import ComposableArchitecture
import SharedEnv
import SharedInterfaces
import Models

struct RootView: View, RootViewHolder {

    @State var tabViewsProvider: RootTabViewsProvider

    let store: Store<RootState, RootAction>
    var viewStore: ViewStore<RootState, RootAction>
    var view: AnyView { .init(self) }

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                TabView {
                    ForEach(viewStore.tabs) { tab in
                        tabViewsProvider
                            .view(for: tab.type)
                            .tabItem {
                                Label(tab.name, systemImage: tab.iconName)
                            }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootFeatureAssemblyImpl.previewMock(isPhone: true)
        }
    }
}
#endif
#endif
