import Foundation
import Testing
@testable import FilePath

extension FilePathTests {
    @Suite
    struct Read {
        @Test(arguments: [
            ("dir1/subdir_1/subdir_2/1.txt", "1"),
            ("dir1/subdir_1/subdir_2/2.txt", "2"),
            ("dir1/subdir_1/subdir_2/3.txt", "3"),
            ("dir1/subdir_1/subdir_2/4.txt", "4"),
            ("dir1/subdir_1/subdir_2/5.txt", "5"),
        ])
        func success(_ path: String, _ expected: String) async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: path))
            try #require(path.exists)
            try #require(path.isFile)
            let content = try path.read()
            #expect(content == Data(expected.utf8))
        }

        @Test
        func notExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing.txt"))
            try #require(!path.exists)
            let error = try #require(throws: ReadError.self) {
                try path.read()
            }
            #expect(error == .notExist(path))
        }

        @Test
        func notReadable() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "unreachable_file.txt"))
            try #require(path.exists)
            try withKnownIssue("Running with root privileges, files without read permission still can be read.") {
                let error = try #require(throws: ReadError.self) {
                    try path.read()
                }
                #expect(error == .notReadable(path))
            } when: {
                geteuid() == 0 // Root user
            }
        }

        @Test
        func notFile() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            try #require(path.exists)
            try #require(path.isDirectory)
            let error = try #require(throws: ReadError.self) {
                try path.read()
            }
            #expect(error == .notFile(path))
        }
    }

    @Suite
    struct ReadString {
        @Test(arguments: [
            ("dir1/subdir_1/subdir_2/1.txt", "1"),
            ("dir1/subdir_1/subdir_2/2.txt", "2"),
            ("dir1/subdir_1/subdir_2/3.txt", "3"),
            ("dir1/subdir_1/subdir_2/4.txt", "4"),
            ("dir1/subdir_1/subdir_2/5.txt", "5"),
        ])
        func success(_ path: String, _ expected: String) async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: path))
            try #require(path.exists)
            try #require(path.isFile)
            let content = try path.readString()
            #expect(content == expected)
        }

        @Test
        func notExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing.txt"))
            try #require(!path.exists)
            let error = try #require(throws: ReadError.self) {
                try path.readString()
            }
            #expect(error == .notExist(path))
        }

        @Test
        func notReadable() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "unreachable_file.txt"))
            try #require(path.exists)
            try withKnownIssue("Running with root privileges, files without read permission still can be read.") {
                let error = try #require(throws: ReadError.self) {
                    try path.readString()
                }
                #expect(error == .notReadable(path))
            } when: {
                geteuid() == 0 // Root user
            }
        }

        @Test
        func notFile() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            try #require(path.exists)
            try #require(path.isDirectory)
            let error = try #require(throws: ReadError.self) {
                try path.readString()
            }
            #expect(error == .notFile(path))
        }

        @Test
        func invalidEncoding() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "invalid_encoding.txt"))
            try #require(path.exists)
            try #require(path.isFile)
            let error = try #require(throws: ReadError.self) {
                try path.readString()
            }
            #expect(error == .invalidEncoding(path))
        }
    }
}
