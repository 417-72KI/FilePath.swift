import Foundation

public enum FileStateError: FilePathError {
    case notExist(FilePath)
    case notDirectory(FilePath)
    case unexpected(origin: any Error)
}

extension FileStateError: Equatable {
    public static func == (lhs: FileStateError, rhs: FileStateError) -> Bool {
        switch (lhs, rhs) {
        case let (.notExist(lhsPath), .notExist(rhsPath)): lhsPath == rhsPath
        case let (.notDirectory(lhsPath), .notDirectory(rhsPath)): lhsPath == rhsPath
        case let (.unexpected(lhsError), .unexpected(rhsError)): (lhsError as NSError) == (rhsError as NSError)
        default: false
        }
    }
}

// MARK: -
extension Error {
    func asFileStateError(filePath: FilePath) -> FileStateError {
        if let fileStateError = self as? FileStateError {
            return fileStateError
        }
        let nsError = self as NSError
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileReadNoSuchFileError:
                return .notExist(filePath)
            case NSFileReadUnknownError:
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? POSIXError,
                   underlyingError.code == .ENOTDIR {
                    return .notDirectory(filePath)
                }
            default: break
            }
        }
        return .unexpected(origin: self)
    }
}
