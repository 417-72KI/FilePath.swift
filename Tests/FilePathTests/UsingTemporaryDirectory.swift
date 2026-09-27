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
        var isDir = ObjCBool(false)
        try #require(fm.fileExists(atPath: tmpDirectory.path(), isDirectory: &isDir) && isDir.boolValue)
        try await setUp(in: tmpDirectory, withFileManager: fm)
        do {
            try await Self.$current.withValue(tmpDirectory) {
                try await function()
            }
        } catch {
            try fm.removeItem(at: tmpDirectory)
            try #require(!fm.fileExists(atPath: tmpDirectory.path()))
            throw error
        }
        try fm.removeItem(at: tmpDirectory)
        try #require(!fm.fileExists(atPath: tmpDirectory.path()))
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

        let testDirectoryURL = directory.appending(
            components: "dir1",
            "dir2",
            "dir3",
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
}

// MARK: -
extension Trait where Self == UsingTemporaryDirectory {
    static var usingTemporaryDirectory: Self {
        Self()
    }
}
