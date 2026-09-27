import Foundation

public struct FilePath {
    let url: URL
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
    func move(to destination: FilePath) throws(FilePathError) -> FilePath {
        do {
            try fm.moveItem(at: url, to: destination.url)
            return destination
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError {
            throw FilePathError.notExists(self)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileWriteFileExistsError {
            throw FilePathError.conflict(self, destination)
        } catch {
            throw FilePathError.unexpected(origin: error)
        }
    }
}
