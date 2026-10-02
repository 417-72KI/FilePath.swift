import Foundation

enum ExistingStatus {
    case file
    case directory
    case notExist
}

// MARK: -
public extension FilePath {
    var exists: Bool { existingStatus != .notExist }

    var isFile: Bool { existingStatus == .file }

    var isDirectory: Bool { existingStatus == .directory }
}

// MARK: -
extension FilePath {
    var existingStatus: ExistingStatus {
        var isDir = ObjCBool(false)
        return if fm.fileExists(atPath: path, isDirectory: &isDir) {
            isDir.boolValue ? .directory : .file
        } else {
            .notExist
        }
    }
}

extension FilePath {
    static let fm = FileManager.default
}

extension FilePath {
    var fm: FileManager { Self.fm }
}
