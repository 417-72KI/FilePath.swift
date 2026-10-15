import Foundation
import Testing
@testable import FilePath

extension FilePathTests {
    @Suite
    struct Write {
        @Test
        func success() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test_output.txt"))
            try #require(!path.exists)
            try await path.write(Data("Hello, World!".utf8))
            try #require(path.exists)
            try #require(path.isFile)
            #expect(try String(contentsOf: path.url, encoding: .utf8) == "Hello, World!")
        }

        @Test
        func successWithForce() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test.txt"))
            try #require(path.exists)
            try #require(try String(contentsOf: path.url, encoding: .utf8) == """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                """)
            try await path.write(Data("Hello, World!".utf8), force: true)
            try #require(path.exists)
            try #require(path.isFile)
            #expect(try String(contentsOf: path.url, encoding: .utf8) == "Hello, World!")
        }

        @Test
        func alreadyExists() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test.txt"))
            try #require(path.exists)
            try #require(try String(contentsOf: path.url, encoding: .utf8) == """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                """)
            let error = try await #require(throws: WriteError.self) {
                try await path.write(Data("Hello, World!".utf8))
            }
            #expect(error == .alreadyExists(path))
            #expect(try String(contentsOf: path.url, encoding: .utf8) == """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                """)
        }

        @Test
        func isDirectory() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            try #require(path.exists)
            try #require(path.isDirectory)
            let error = try await #require(throws: WriteError.self) {
                try await path.write(Data("Hello, World!".utf8))
            }
            #expect(error == .isDirectory(path))
        }

        @Test
        func directoryNotExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_not_exist", directoryHint: .isDirectory))
            try #require(!path.exists)
            let error = try await #require(throws: WriteError.self) {
                try await (path + "test.txt").write(Data("Hello, World!".utf8))
            }
            #expect(error == .directoryNotExist(path))
        }

        @Test
        func permissionDenied() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "unreachable_directory/test.txt"))
            try #require(path.parent.isDirectory)
            try await withKnownIssue("Running with root privileges, files without read permission still can be read.") {
                let error = try await #require(throws: WriteError.self) {
                    try await path.write(Data("Hello, World!".utf8))
                }
                #expect(error == .permissionDenied(path))
            } when: {
                geteuid() == 0 // Root user
            }
        }
    }
}
