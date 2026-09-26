import Foundation

extension FilePath: Equatable {
    nonisolated public static func == (lhs: borrowing FilePath, rhs: borrowing FilePath) -> Bool {
        lhs.url.absoluteURL == rhs.url.absoluteURL
    }
}

extension FilePath: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteURL)
    }
}
