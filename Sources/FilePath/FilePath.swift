import Foundation

public struct FilePath {
    let url: URL
}

extension FilePath {
    public init(_ path: String) {
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
    static var current: Self {
        Self(fm.currentDirectoryPath)
    }
}
