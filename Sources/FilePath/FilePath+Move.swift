import Foundation

public extension FilePath {
    @discardableResult
    nonisolated func move(to destination: FilePath) throws(MoveError) -> FilePath {
        do {
            try fm.moveItem(at: url, to: destination.url)
            return destination
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError {
            throw if exists {
                MoveError.destinationNotExist(destination.parent)
            } else {
                MoveError.sourceNotExist(self)
            }
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileWriteFileExistsError {
            throw MoveError.destinationAlreadyExists(destination)
        } catch {
            throw MoveError.unexpected(origin: error)
        }
    }

    @discardableResult
    nonisolated func move(toDirectory directory: FilePath) throws(MoveError) -> FilePath {
        switch directory.existingStatus {
        case .notExist:
            throw MoveError.destinationNotExist(directory)
        case .file:
            throw MoveError.destinationIsNotDirectory(directory)
        case .directory:
            let destination = directory + url.lastPathComponent
            return try move(to: destination)
        }
    }
}
