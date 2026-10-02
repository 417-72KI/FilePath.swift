import Foundation

public struct FilePath {
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
