import Foundation

public enum MoveError: FilePathError {
    case sourceNotExist(FilePath)
    case sourceIsNotDirectory(FilePath)
    case destinationNotExist(FilePath)
    case destinationIsNotDirectory(FilePath)
    case destinationAlreadyExists(FilePath)
    case unexpected(origin: any Error)
}

extension MoveError: Equatable {
    nonisolated public static func == (lhs: MoveError, rhs: MoveError) -> Bool {
        switch (lhs, rhs) {
        case let (.sourceNotExist(lhsPath), .sourceNotExist(rhsPath)): lhsPath == rhsPath
        case let (.sourceIsNotDirectory(lhsPath), .sourceIsNotDirectory(rhsPath)): lhsPath == rhsPath
        case let (.destinationNotExist(lhsPath), .destinationNotExist(rhsPath)): lhsPath == rhsPath
        case let (.destinationIsNotDirectory(lhsPath), .destinationIsNotDirectory(rhsPath)): lhsPath == rhsPath
        case let (.destinationAlreadyExists(lhsPath), .destinationAlreadyExists(rhsPath)): lhsPath == rhsPath
        case let (.unexpected(lhsError), .unexpected(rhsError)): lhsError.localizedDescription == rhsError.localizedDescription
        default: false
        }
    }
}
