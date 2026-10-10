import Foundation

public extension FilePath {
    nonisolated var children: [FilePath] {
        get throws {
            do {
                let contents = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                return contents.map(Self.init)
            } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
                throw FileStateError.notExist(self)
            } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadUnknownError {
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                    if underlyingError.domain == NSPOSIXErrorDomain,
                       underlyingError.code == Int(ENOTDIR) {
                        throw FileStateError.notDirectory(self)
                    }
                }
                throw FileStateError.unexpected(origin: error)
            } catch {
                throw FileStateError.unexpected(origin: error)
            }
        }
    }
}
