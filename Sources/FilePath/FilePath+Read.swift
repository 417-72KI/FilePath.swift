public import Foundation

public extension FilePath {
    nonisolated func read() throws(ReadError) -> Data {
        do {
            return try Data(contentsOf: url)
        } catch {
            throw error.asReadError(self)
        }
    }

    nonisolated func readString(encoding: String.Encoding = .utf8) throws(ReadError) -> String {
        let data = try read()
        guard let string = String(data: data, encoding: encoding) else {
            throw ReadError.invalidEncoding(self)
        }
        return string
    }
}

// MARK: -
public enum ReadError: FilePathError {
    case notExist(FilePath)
    case notReadable(FilePath)
    case notFile(FilePath)
    case invalidEncoding(FilePath)
    case unexpected(origin: any Error)
}

extension ReadError: Equatable {
    nonisolated public static func == (lhs: ReadError, rhs: ReadError) -> Bool {
        switch (lhs, rhs) {
        case let (.notExist(lhsPath), .notExist(rhsPath)): lhsPath == rhsPath
        case let (.notReadable(lhsPath), .notReadable(rhsPath)): lhsPath == rhsPath
        case let (.notFile(lhsPath), .notFile(rhsPath)): lhsPath == rhsPath
        case let (.invalidEncoding(lhsPath), .invalidEncoding(rhsPath)): lhsPath == rhsPath
        case let (.unexpected(lhsError), .unexpected(rhsError)): (lhsError as NSError) == (rhsError as NSError)
        default: false
        }
    }
}

// MARK: -
private extension Error {
    nonisolated func asReadError(_ filePath: FilePath) -> ReadError {
        if let readError = self as? ReadError {
            return readError
        }
        let nsError = self as NSError
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileReadNoSuchFileError:
                return .notExist(filePath)
            case NSFileReadNoPermissionError:
                return .notReadable(filePath)
            case NSFileReadUnknownError:
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? POSIXError,
                   underlyingError.code == .EISDIR {
                    return .notFile(filePath)
                }
            default: break
            }
        }
        return .unexpected(origin: self)
    }
}
