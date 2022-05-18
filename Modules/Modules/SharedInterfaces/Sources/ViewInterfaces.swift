import SwiftUI

public protocol ViewHolder {
    var view: AnyView { get }
}

public protocol RootViewHolder: ViewHolder {}
public protocol CatalogViewHolder: ViewHolder {}
