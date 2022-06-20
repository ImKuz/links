import Models
import Contracts
import GRPC

@testable import CatalogClient

struct CatalogSourceClientFactoryFake: CatalogSourceClientFactory {

    let source: Catalog_SourceTestClient

    init(source: Catalog_SourceTestClient) {
        self.source = source
    }

    func make(
        host: String,
        port: Int,
        connectivityStateDelegate: ConnectivityStateDelegate
    ) -> Catalog_SourceClientProtocol {
        source
    }
}
