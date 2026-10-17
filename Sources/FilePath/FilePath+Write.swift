public import Foundation

public extension FilePath {
    func write(_ data: Data, force: Bool = false) throws(WriteError) {
        guard parent.exists else { throw .directoryNotExist(parent) }
        guard !isDirectory else { throw .isDirectory(self) }
        do {
            var options: Data.WritingOptions = [.atomic]
            if !force {
                options = .withoutOverwriting
            }
            try data.write(to: url, options: options)
        } catch {
            throw error.asWriteError(self)
        }
    }

    func writeString(
        _ string: String,
        encoding: String.Encoding = .utf8,
        force: Bool = false
    ) throws(WriteError) {
        guard let data = string.data(using: encoding) else {
            throw .unsupportedEncoding(encoding)
        }
        try write(data, force: force)
    }
}

// MARK:
public enum WriteError: FilePathError {
    case directoryNotExist(FilePath)
    case isDirectory(FilePath)
    case alreadyExists(FilePath)
    case permissionDenied(FilePath)
    case unsupportedEncoding(String.Encoding)
    case unexpected(origin: any Error)
}

extension WriteError: Equatable {
    public static func == (lhs: WriteError, rhs: WriteError) -> Bool {
        switch (lhs, rhs) {
        case let (.directoryNotExist(lhsPath), .directoryNotExist(rhsPath)): lhsPath == rhsPath
        case let (.isDirectory(lhsPath), .isDirectory(rhsPath)): lhsPath == rhsPath
        case let (.alreadyExists(lhsPath), .alreadyExists(rhsPath)): lhsPath == rhsPath
        case let (.permissionDenied(lhsPath), .permissionDenied(rhsPath)): lhsPath == rhsPath
        case let (.unsupportedEncoding(lhsEncoding), .unsupportedEncoding(rhsEncoding)): lhsEncoding == rhsEncoding
        case let (.unexpected(lhsError), .unexpected(rhsError)): (lhsError as NSError) == (rhsError as NSError)
        default: false
        }
    }
}

private extension Error {
    func asWriteError(_ filePath: FilePath) -> WriteError {
        if let writeError = self as? WriteError {
            return writeError
        }
        let nsError = self as NSError
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileWriteFileExistsError:
                return .alreadyExists(filePath)
            case NSFileWriteNoPermissionError:
                return .permissionDenied(filePath)
            default: break
            }
        }
        return .unexpected(origin: self)
    }
}
