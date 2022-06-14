import Foundation

public enum DatabaseErrorCode: Int {

    case invalidType
    case unableToWrite
    case unableToLoad
    case failiedToMigrate
    case common
}

public struct DatabaseError: Error {

    let code: DatabaseErrorCode
    let description: String

    init(code: DatabaseErrorCode, description: String) {
        self.code = code
        self.description = description
    }

    var errorDescription: String? {
        NSLocalizedString(description, comment: "")
    }
}
