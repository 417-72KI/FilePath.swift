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
    // swiftlint:disable:next function_body_length
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
                try "\($0)".write(
                    to: testDirectoryURL.appending(path: "\($0).txt"),
                    atomically: true,
                    encoding: .utf8
                )
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

        try fm.createDirectory(
            at: directory.appending(
                components: "dir_empty",
                directoryHint: .isDirectory
            ),
            withIntermediateDirectories: true
        )

        let anotherEncodingFileURL = directory.appending(path: "another_encoding.txt")
        // swiftlint:disable:next no_magic_numbers
        try Data([0x82, 0xa0, 0x82, 0xa2, 0x82, 0xa4, 0x82, 0xa6, 0x82, 0xa8])
            .write(to: anotherEncodingFileURL)
        // try #require(String(contentsOf: anotherEncodingFileURL, encoding: .shiftJIS) == "あいうえお")

        let invalidEncodingFileURL = directory.appending(path: "invalid_encoding.txt")
        // "あいうえ" with UTF-8 and "お" with Shift-JIS
        // swiftlint:disable:next no_magic_numbers
        try Data([0xE3, 0x81, 0x82, 0xE3, 0x81, 0x84, 0xE3, 0x81, 0x86, 0xE3, 0x81, 0x88, 0x82, 0xa8])
            .write(to: invalidEncodingFileURL)

        try directory.appending(path: "unreachable_file.txt").apply {
            try "unreachable".write(
                to: $0,
                atomically: true,
                encoding: .utf8
            )
            try fm.setAttributes(
                [.posixPermissions: 000],
                ofItemAtPath: $0.path()
            )
        }

        try directory.appending(path: "unreachable_directory").apply {
            try fm.createDirectory(
                at: $0,
                withIntermediateDirectories: true
            )
            try "This file is unreachable".write(
                to: $0.appending(path: "test.txt"),
                atomically: true,
                encoding: .utf8
            )
            try fm.setAttributes(
                [.posixPermissions: 0o000],
                ofItemAtPath: $0.path()
            )
        }

        try directory.appending(path: "readonly_directory").apply {
            try fm.createDirectory(
                at: $0,
                withIntermediateDirectories: true
            )
            try fm.setAttributes(
                [.posixPermissions: 0o555],
                ofItemAtPath: $0.path()
            )
        }
    }

    func cleanUp(
        _ directory: URL,
        withFileManager fm: FileManager
    ) throws {
        try directory.appending(path: "unreachable_directory").apply {
            if fm.fileExists(atPath: $0.path()) {
                try fm.setAttributes(
                    [.posixPermissions: 0o755],
                    ofItemAtPath: $0.path()
                )
            }
        }
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

// MARK: -
private extension URL {
    @discardableResult
    func apply(_ closure: (URL) throws -> Void) rethrows -> URL {
        try closure(self)
        return self
    }
}
