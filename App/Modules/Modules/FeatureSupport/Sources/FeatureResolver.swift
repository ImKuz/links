import Swinject

public protocol FeatureResolver {
    func resolve<Feature: FeatureInterface>(feature: Feature.Type, input: Feature.Input) -> Feature
}

public extension FeatureResolver {

    func resolve<Feature: FeatureInterface>(_ feature: Feature.Type) -> Feature where Feature.Input == Void {
        resolve(feature: feature, input: ())
    }
}

final class FeatureResolverImpl: FeatureResolver {

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func resolve<Feature: FeatureInterface>(feature: Feature.Type, input: Feature.Input) -> Feature {
        guard let feature = container.resolve(feature, argument: input) else {
            fatalError("Unable to resolve feature: \(Feature.self)")
        }

        return feature
    }
}
