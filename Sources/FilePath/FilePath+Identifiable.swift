import Foundation

extension FilePath: Identifiable {
    public var id: String { url.absoluteString }
}
