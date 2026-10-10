import Foundation

public extension FilePath {
    nonisolated var children: [FilePath] {
        get throws {
            #if os(Linux)
            // On Linux, `contentsOfDirectory(at:includingPropertiesForKeys:)` won't throw an error if the path is a file, but will return an empty array. So we need to check if it's a file first.
            if isFile { throw FileStateError.notDirectory(self) }
            #endif
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

    nonisolated var descendants: [FilePath] {
        get throws {
            switch existingStatus {
            case .notExist: throw FileStateError.notExist(self)
            case .file: throw FileStateError.notDirectory(self)
            case .directory: break
            }
            var children = [URL]()
            let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: nil)
            while let url = enumerator?.nextObject() as? URL {
                children.append(url)
            }
            return children.sorted { $0.path() < $1.path() }.map(Self.init)
        }
    }
}
