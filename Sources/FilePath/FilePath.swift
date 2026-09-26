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

public extension FilePath {
    static var current: Self {
        Self(fm.currentDirectoryPath)
    }
}

// MARK: -
extension FilePath: Identifiable {
    public var id: String { url.absoluteString }
}

// MARK: -
extension FilePath: CustomStringConvertible {
    public nonisolated var description: String { absolutePath }
}

// MARK: -
private extension FilePath {
    static let fm = FileManager.default
}

private extension FilePath {
    var fm: FileManager { Self.fm }
}
