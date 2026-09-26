import Foundation

extension FilePath {
    static let fm = FileManager.default
}

extension FilePath {
    var fm: FileManager { Self.fm }
}
