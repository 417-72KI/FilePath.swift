import Foundation

public enum FileStateError: FilePathError {
    case notExist(FilePath)
    case notDirectory(FilePath)
    case unexpected(origin: any Error)
}

extension FileStateError: Equatable {
    nonisolated public static func == (lhs: FileStateError, rhs: FileStateError) -> Bool {
        switch (lhs, rhs) {
        case let (.notExist(lhsPath), .notExist(rhsPath)): lhsPath == rhsPath
        case let (.notDirectory(lhsPath), .notDirectory(rhsPath)): lhsPath == rhsPath
        case let (.unexpected(lhsError), .unexpected(rhsError)): (lhsError as NSError) == (rhsError as NSError)
        default: false
        }
    }
}
