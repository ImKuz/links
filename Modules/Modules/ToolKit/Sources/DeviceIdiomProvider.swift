#if os(iOS)
import UIKit
#endif

// TODO: Make protocol and move to DI
public final class DeviceIdiomProvider {

    public enum DeviceType {
        case phone
        case pad
        case mac
    }

    public static var shared = DeviceIdiomProvider()

    private init() {}

    public var deviceType: DeviceType {
        #if os(OSX)
        return .mac
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
        #else
        fatalError()
        #endif
    }
}
