import Foundation

public enum FilePathError: Error {
    case notExists(FilePath)
    case notDirectory(FilePath)
    case fileAlreadyExists(FilePath)
    case conflict(FilePath, FilePath)
    case unexpected(origin: any Error)
}

extension FilePathError: Equatable {
    public static func == (lhs: FilePathError, rhs: FilePathError) -> Bool {
        switch (lhs, rhs) {
        case let (.notExists(lhsPath), .notExists(rhsPath)):
            lhsPath == rhsPath
        case let (.notDirectory(lhsPath), .notDirectory(rhsPath)):
            lhsPath == rhsPath
        case let (.fileAlreadyExists(lhsPath), .fileAlreadyExists(rhsPath)):
            lhsPath == rhsPath
        case let (.conflict(lhsPath1, lhsPath2), .conflict(rhsPath1, rhsPath2)):
            lhsPath1 == rhsPath1 && lhsPath2 == rhsPath2
        case let (.unexpected(lhs), .unexpected(rhs)):
            lhs.localizedDescription == rhs.localizedDescription
        default: false
        }
    }
}
