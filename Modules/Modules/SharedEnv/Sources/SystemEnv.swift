import ComposableArchitecture
import CombineSchedulers
import SwiftUI

@dynamicMemberLookup
public struct SystemEnv<Environment> {
    public var environment: Environment
    
    public subscript<Dependency>(
        dynamicMember keyPath: WritableKeyPath<Environment, Dependency>
    ) -> Dependency {
        get { self.environment[keyPath: keyPath] }
        set { self.environment[keyPath: keyPath] = newValue }
    }
    
    public var mainQueue: () -> AnySchedulerOf<DispatchQueue>
    
    public static func make(environment: Environment) -> Self {
        Self(
            environment: environment,
            mainQueue: { .main }
        )
    }
}
