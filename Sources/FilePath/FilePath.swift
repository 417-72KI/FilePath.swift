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
    var path: String { url.path(percentEncoded: false) }

    var absolutePath: String { url.absoluteURL.path(percentEncoded: false) }
}

public extension FilePath {
    var parent: FilePath {
        FilePath(url: url.deletingLastPathComponent())
    }
}

// MARK: -
public extension FilePath {
    static func + (lhs: FilePath, rhs: String) -> FilePath {
        FilePath(url: lhs.url.appending(path: rhs))
    }
}

// MARK: -
public extension FilePath {
    static var current: Self {
        Self(url: .currentDirectory())
    }

    static var home: Self {
        Self(url: .homeDirectory)
    }
}
