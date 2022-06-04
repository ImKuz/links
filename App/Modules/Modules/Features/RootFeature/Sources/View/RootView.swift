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
            TabView {
                ForEach(viewStore.tabs) { tab in
                    tabViewsProvider
                        .view(for: tab.type)?
                        .ignoresSafeArea()
                        .background(Color(UIColor.secondarySystemBackground))
                        .tabItem {
                            Label(tab.name, systemImage: tab.iconName)
                        }
                }
            }
        }
    }
}
