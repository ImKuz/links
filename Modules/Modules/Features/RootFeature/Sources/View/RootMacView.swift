import SwiftUI
import ComposableArchitecture
import SharedInterfaces

struct RootMacView: View, RootViewHolder {

    @State var tabViewsProvider: RootTabViewsProvider
    let store: Store<RootState, RootAction>
    var viewStore: ViewStore<RootState, RootAction>
    var view: AnyView { .init(self) }

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometry in
                HStack {
                    VStack {
                        LazyVStack(spacing: 12) {
                            ForEach(viewStore.tabs) { tab in
                                Image(systemName: tab.iconName)
                            }
                        }
                        .padding(16)
                        .frame(
                            width: 56,
                            height: geometry.size.height,
                            alignment: .top
                        )
                        Spacer()
                    }
                    .background(Color.gray)
                    VStack {
                        HStack {
                            Text("Local")
                                .font(.system(size: 24))
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(
                            EdgeInsets(
                                top: 12,
                                leading: 12,
                                bottom: 12,
                                trailing: 0
                            )
                        )
                        Spacer()
                        tabViewsProvider.view(for: viewStore.selectedTab.type)
                        Spacer()
                    }
                    .frame(width: geometry.size.width - 32 - 16 * 2)
                }
            }
        }
    }
}

struct RootMacView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootFeatureAssemblyImpl.previewMock(isPhone: false)
        }
    }
}
