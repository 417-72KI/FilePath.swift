import Foundation

public extension FilePath {
    var exists: Bool { fm.fileExists(atPath: path) }

    var isFile: Bool {
        var isDir = ObjCBool(false)
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return false }
        return !isDir.boolValue
    }

    var isDirectory: Bool {
        var isDir = ObjCBool(false)
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return false }
        return isDir.boolValue
    }
}

extension FilePath {
    static let fm = FileManager.default
}

extension FilePath {
    var fm: FileManager { Self.fm }
}
