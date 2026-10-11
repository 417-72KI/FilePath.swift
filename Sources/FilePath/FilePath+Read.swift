public import Foundation

public extension FilePath {
    nonisolated func read() throws(ReadError) -> Data {
        do {
            return try Data(contentsOf: url)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
            throw ReadError.notExist(self)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoPermissionError {
            throw ReadError.notReadable(self)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadUnknownError {
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? POSIXError,
               underlyingError.code == .EISDIR {
                throw ReadError.notFile(self)
            }
            throw ReadError.unexpected(origin: error)
        } catch {
            throw ReadError.unexpected(origin: error)
        }
    }

    nonisolated func readString(encoding: String.Encoding = .utf8) throws(ReadError) -> String {
        do {
            return try String(contentsOf: url, encoding: encoding)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
            throw ReadError.notExist(self)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoPermissionError {
            throw ReadError.notReadable(self)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadUnknownError {
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? POSIXError,
               underlyingError.code == .EISDIR {
                throw ReadError.notFile(self)
            }
            throw ReadError.unexpected(origin: error)
        } catch {
            throw ReadError.unexpected(origin: error)
        }
    }
}

// MARK: -
public enum ReadError: FilePathError {
    case notExist(FilePath)
    case notReadable(FilePath)
    case notFile(FilePath)
    case unexpected(origin: any Error)
}

extension ReadError: Equatable {
    nonisolated public static func == (lhs: ReadError, rhs: ReadError) -> Bool {
        switch (lhs, rhs) {
        case let (.notExist(lhsPath), .notExist(rhsPath)): lhsPath == rhsPath
        case let (.notReadable(lhsPath), .notReadable(rhsPath)): lhsPath == rhsPath
        case let (.notFile(lhsPath), .notFile(rhsPath)): lhsPath == rhsPath
        case let (.unexpected(lhsError), .unexpected(rhsError)): (lhsError as NSError) == (rhsError as NSError)
        default: false
        }
    }
}
