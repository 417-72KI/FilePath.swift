import Foundation

public struct FilePath {
    let url: URL
}

public extension FilePath {
    init(_ path: String) {
        self.url = URL(
            filePath: path,
            relativeTo: .currentDirectory()
        )
    }
}

public extension FilePath {
    nonisolated var path: String { url.path(percentEncoded: false) }

    nonisolated var absolutePath: String { url.absoluteURL.path(percentEncoded: false) }
}

public extension FilePath {
    var exists: Bool { fm.fileExists(atPath: path) }

    var isFile: Bool {
        var isDir = ObjCBool(false)
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return false }
        return !isDir.boolValue
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
    static var current: Self {
        Self(fm.currentDirectoryPath)
    }
}
