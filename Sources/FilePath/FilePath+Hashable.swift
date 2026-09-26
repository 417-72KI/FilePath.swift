import Foundation

extension FilePath: Hashable {
    public nonisolated static func == (lhs: borrowing FilePath, rhs: borrowing FilePath) -> Bool {
        lhs.url.absoluteURL == rhs.url.absoluteURL
    }

    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteURL)
    }
}
