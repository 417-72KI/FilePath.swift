import Foundation

extension FilePath: Equatable {
    nonisolated public static func == (lhs: borrowing FilePath, rhs: borrowing FilePath) -> Bool {
        lhs.url.absoluteURL == rhs.url.absoluteURL
    }
}

// MARK: - Hashable
extension FilePath: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteURL)
    }
}

// MARK: - Comparable
extension FilePath: Comparable {
    nonisolated public static func < (lhs: borrowing FilePath, rhs: borrowing FilePath) -> Bool {
        lhs.url.absoluteURL.path() < rhs.url.absoluteURL.path()
    }
}
