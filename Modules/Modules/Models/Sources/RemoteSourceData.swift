public struct RemoteSourceData: Equatable {

    public let host: String
    public let port: Int

    public static var `default`: Self {
        .init(host: "localhost", port: 8089)
    }

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
}
