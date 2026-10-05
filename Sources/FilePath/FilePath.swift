import Foundation

public struct FilePath: Sendable {
    var url: URL
}

public extension FilePath {
    init(_ path: String) {
        self.url = URL(
            filePath: path,
            directoryHint: .checkFileSystem,
            relativeTo: .currentDirectory()
        )
    }
}

public extension FilePath {
    nonisolated var path: String { url.path(percentEncoded: false) }

    nonisolated var absolutePath: String { url.absoluteURL.path(percentEncoded: false) }
}

public extension FilePath {
    nonisolated var parent: FilePath {
        FilePath(url: url.deletingLastPathComponent())
    }
}

// MARK: -
public extension FilePath {
    nonisolated static func + (lhs: FilePath, rhs: String) -> FilePath {
        FilePath(url: lhs.url.appending(path: rhs))
    }
}

// MARK: -
public extension FilePath {
    nonisolated static var current: Self {
        Self(url: .currentDirectory())
    }

    nonisolated static var home: Self {
        Self(url: .homeDirectory)
    }
}

// MARK: -
public extension FilePath {
    @discardableResult
    func move(to destination: FilePath) throws(MoveError) -> FilePath {
        guard exists else {
            throw MoveError.sourceNotExist(self)
        }
        switch destination.parent.existingStatus {
        case .notExist:
            throw MoveError.destinationNotExist(destination.parent)
        case .file:
            throw MoveError.destinationIsNotDirectory(destination.parent)
        case .directory:
            break
        }
        guard !destination.exists else {
            throw MoveError.destinationAlreadyExists(destination)
        }
        do {
            try fm.moveItem(at: url, to: destination.url)
            return destination
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError {
            throw MoveError.sourceNotExist(self)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileWriteFileExistsError {
            throw MoveError.destinationAlreadyExists(destination)
        } catch {
            throw MoveError.unexpected(origin: error)
        }
    }

    func move(toDirectory directory: FilePath) throws(MoveError) -> FilePath {
        switch directory.existingStatus {
        case .notExist:
            throw MoveError.destinationNotExist(directory)
        case .file:
            throw MoveError.destinationIsNotDirectory(directory)
        case .directory:
            let destination = directory + url.lastPathComponent
            return try move(to: destination)
        }
    }
}
