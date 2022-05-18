public enum CatalogDataSource {
    case local
    case favorites
    case remote(RemoteSourceData)
}
