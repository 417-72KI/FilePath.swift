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
            try path.write(Data("Hello, World!".utf8))
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
            try path.write(Data("Hello, World!".utf8), force: true)
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
            let error = try #require(throws: WriteError.self) {
                try path.write(Data("Hello, World!".utf8))
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
            let error = try #require(throws: WriteError.self) {
                try path.write(Data("Hello, World!".utf8))
            }
            #expect(error == .isDirectory(path))
        }

        @Test
        func notExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_not_exist/test.txt"))
            try #require(!path.parent.exists)
            let error = try #require(throws: WriteError.self) {
                try path.write(Data("Hello, World!".utf8))
            }
            #expect(error == .notExist(path))
        }

        @Test
        func permissionDenied() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "readonly_directory/test.txt"))
            try #require(path.parent.isDirectory)
            try withKnownIssue("Running with root privileges, files without read permission still can be read.") {
                let error = try #require(throws: WriteError.self) {
                    try path.write(Data("Hello, World!".utf8))
                }
                #expect(error == .permissionDenied(path))
            } when: {
                geteuid() == 0 // Root user
            }
        }
    }

    @Suite
    struct WriteString {
        @Test
        func success() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test_output.txt"))
            try #require(!path.exists)
            try path.writeString("Hello, World!")
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
            try path.writeString("Hello, World!", force: true)
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
            let error = try #require(throws: WriteError.self) {
                try path.writeString("Hello, World!")
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
            let error = try #require(throws: WriteError.self) {
                try path.writeString("Hello, World!")
            }
            #expect(error == .isDirectory(path))
        }

        @Test
        func notExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_not_exist/test.txt"))
            try #require(!path.parent.exists)
            let error = try #require(throws: WriteError.self) {
                try path.writeString("Hello, World!")
            }
            #expect(error == .notExist(path))
        }

        @Test
        func permissionDenied() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "readonly_directory/test.txt"))
            try #require(path.parent.isDirectory)
            try withKnownIssue("Running with root privileges, files without read permission still can be read.") {
                let error = try #require(throws: WriteError.self) {
                    try path.writeString("Hello, World!")
                }
                #expect(error == .permissionDenied(path))
            } when: {
                geteuid() == 0 // Root user
            }
        }

        @Test
        func unsupportedEncoding() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test_output.txt"))
            try #require(!path.exists)
            try withKnownIssue("EUC-JP is installed in this environment.") {
                let error = try #require(throws: WriteError.self) {
                    try path.writeString("あいうえお", encoding: .japaneseEUC)
                }
                #expect(error == .unsupportedEncoding(.japaneseEUC))
            } when: {
                String.availableStringEncodings.contains(.japaneseEUC)
            }
        }
    }
}
