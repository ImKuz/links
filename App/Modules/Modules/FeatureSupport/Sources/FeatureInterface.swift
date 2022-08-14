import SwiftUI
import ToolKit
import Combine
import Models
import UIKit

public protocol FeatureInterface {

    associatedtype Input

    var view: AnyView { get }
}
