import Foundation

nonisolated enum ExistingStatus {
    case file
    case directory
    case notExist
}

// MARK: -
public extension FilePath {
    nonisolated var exists: Bool { existingStatus != .notExist }

    nonisolated var isFile: Bool { existingStatus == .file }

    nonisolated var isDirectory: Bool { existingStatus == .directory }
}

// MARK: -
extension FilePath {
    nonisolated var existingStatus: ExistingStatus {
        var isDir = ObjCBool(false)
        return if fm.fileExists(atPath: path, isDirectory: &isDir) {
            isDir.boolValue ? .directory : .file
        } else {
            .notExist
        }
    }
}

extension FilePath {
    nonisolated var fm: FileManager { .default }
}
