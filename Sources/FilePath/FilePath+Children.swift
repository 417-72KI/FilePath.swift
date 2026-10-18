import Foundation

public extension FilePath {
    var children: [FilePath] {
        get throws {
            #if os(Linux)
            // On Linux, `contentsOfDirectory(at:includingPropertiesForKeys:)` won't throw an error if the path is a file, but will return an empty array. So we need to check if it's a file first.
            if isFile { throw FileStateError.notDirectory(self) }
            #endif
            do {
                let contents = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                return contents.map(Self.init)
            } catch {
                throw error.asFileStateError(filePath: self)
            }
        }
    }

    var descendants: [FilePath] {
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
