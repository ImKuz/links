import SwiftUI
import ComposableArchitecture
import ToolKit
import SharedInterfaces
import Models

struct RootView: View {

    @State var tabViewsProvider: RootTabViewsProvider

    let store: Store<RootState, RootAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: { $0.selectedTab },
                    send: { RootAction.tabChanged($0) }
                )
            ) {
                ForEach(Array(viewStore.tabs.enumerated()), id: \.0) { index, tab in
                    tabViewsProvider
                        .view(for: tab.type)?
                        .background(Color(UIColor.secondarySystemBackground))
                        .tabItem { Label(tab.name, systemImage: tab.iconName) }
                        .tag(index)
                }
            }
        }
    }
}
