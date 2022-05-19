public protocol ClipboardService {
    func read() -> String?
    func write(_ content: String)
}
