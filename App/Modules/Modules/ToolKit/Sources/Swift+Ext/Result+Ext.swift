extension Result {

    public var data: Success? {
        switch self {
        case .success(let data):
            return data
        case .failure:
            return nil
        }
    }

    public var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    func onSuccess(_ closure: (Success) -> ()) {
        switch self {
        case .success(let success):
            closure(success)
        case .failure:
            break
        }
    }

    func onFailure(_ closure: (Failure) -> ()) {
        switch self {
        case .success:
            break
        case .failure(let error):
            closure(error)
        }
    }
}
