import Contracts
import GRPC

protocol CatalogSourceClientFactory {
    func make(
        host: String,
        port: Int,
        connectivityStateDelegate: ConnectivityStateDelegate
    ) -> Catalog_SourceClientProtocol
}

struct CatalogSourceClientFactoryImpl: CatalogSourceClientFactory {

    func make(
        host: String,
        port: Int,
        connectivityStateDelegate: ConnectivityStateDelegate
    ) -> Catalog_SourceClientProtocol {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .insecure(group: group)
            .withKeepalive(
                .init(
                    interval: .seconds(120),
                    timeout: .seconds(60),
                    permitWithoutCalls: true
                )
            )
            .connect(host: host, port: port)

        channel.connectivity.delegate = connectivityStateDelegate

        return Catalog_SourceClient(channel: channel)
    }
}
