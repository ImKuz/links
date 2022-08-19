import Swinject

public struct FeatureResolverAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(FeatureResolver.self) { _ in
            FeatureResolverImpl(container: container)
        }
    }
}
