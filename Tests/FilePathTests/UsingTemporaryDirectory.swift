import Foundation
import Testing

struct UsingTemporaryDirectory: TestTrait, TestScoping {
    @TaskLocal static var current: URL = .currentDirectory()

    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @concurrent () async throws -> Void
    ) async throws {
        let fm = FileManager.default
        let tmpDirectory = fm.temporaryDirectory
            .appending(
                path: "FilePathTests-\(UUID().uuidString)",
                directoryHint: .isDirectory
            )
        try fm.createDirectory(
            at: tmpDirectory,
            withIntermediateDirectories: true,
        )
        do {
            var isDir = ObjCBool(false)
            try #require(fm.fileExists(atPath: tmpDirectory.path(), isDirectory: &isDir) && isDir.boolValue)
            try await setUp(in: tmpDirectory, withFileManager: fm)
            try await Self.$current.withValue(tmpDirectory) {
                try await function()
            }
        } catch {
            try cleanUp(tmpDirectory, withFileManager: fm)
            throw error
        }
        try cleanUp(tmpDirectory, withFileManager: fm)
    }
}

extension UsingTemporaryDirectory: SuiteTrait {
    var isRecursive: Bool { true }
}

private extension UsingTemporaryDirectory {
    func setUp(
        in directory: URL,
        withFileManager fm: FileManager
    ) async throws {
        try """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """.write(
                to: directory.appending(path: "test.txt"),
                atomically: true,
                encoding: .utf8
            )
        let directoriesToCreate = 2
        try (1...directoriesToCreate).forEach {
            let testDirectoryURL = directory.appending(
                components: "dir\($0)",
                "subdir_1",
                "subdir_2",
                directoryHint: .isDirectory
            )
            try fm.createDirectory(
                at: testDirectoryURL,
                withIntermediateDirectories: true
            )
            let filesToCreate = 5
            try (1...filesToCreate).forEach {
                let fileURL = testDirectoryURL.appending(path: "\($0).txt")
                try "\($0)".write(to: fileURL, atomically: true, encoding: .utf8)
            }
            let fileURLs = try fm.contentsOfDirectory(
                at: testDirectoryURL,
                includingPropertiesForKeys: [.isRegularFileKey]
            )
            try #require(fileURLs.count == filesToCreate)
        }
        let directoryURLs = try fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey]
        )
        try #require(directoryURLs.filter(\.hasDirectoryPath).count == directoriesToCreate)
        let testEmptyDirectoryURL = directory.appending(
            components: "dir_empty",
            directoryHint: .isDirectory
        )
        try fm.createDirectory(
            at: testEmptyDirectoryURL,
            withIntermediateDirectories: true
        )
    }

    func cleanUp(
        _ directory: URL,
        withFileManager fm: FileManager
    ) throws {
        try fm.removeItem(at: directory)
        try #require(!fm.fileExists(atPath: directory.path()))
    }
}

// MARK: -
extension Trait where Self == UsingTemporaryDirectory {
    static var usingTemporaryDirectory: Self {
        Self()
    }
}
