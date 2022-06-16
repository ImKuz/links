public enum AppAssemblerFactory {
    
    public static func make() -> AppAssembler {
        AppAssemblerImpl()
    }
}
