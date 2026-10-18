import Foundation

extension FilePath: Equatable {
    public static func == (lhs: borrowing FilePath, rhs: borrowing FilePath) -> Bool {
        lhs.url.absoluteURL == rhs.url.absoluteURL
    }
}

// MARK: - Hashable
extension FilePath: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteURL)
    }
}

// MARK: - Comparable
extension FilePath: Comparable {
    public static func < (lhs: borrowing FilePath, rhs: borrowing FilePath) -> Bool {
        lhs.url.absoluteURL.path() < rhs.url.absoluteURL.path()
    }
}
