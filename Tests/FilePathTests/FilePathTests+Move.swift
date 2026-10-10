import Foundation
import Testing
@testable import FilePath

extension FilePathTests {
    @Suite
    struct Move {
        @Test
        func file() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test.txt"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test_moved.txt"))
            try #require(path.exists)
            try #require(path.isFile)
            try #require(!destinationPath.exists)
            let result = try path.move(to: destinationPath)
            #expect(result == destinationPath)
            #expect(!path.exists)
            #expect(destinationPath.exists)
            #expect(destinationPath.isFile)
        }

        @Test
        func directory() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1_moved"))
            try #require(path.exists)
            try #require(path.isDirectory)
            try #require(!destinationPath.exists)
            let result = try path.move(to: destinationPath)
            #expect(result == destinationPath)
            #expect(!path.exists)
            #expect(destinationPath.exists)
            #expect(destinationPath.isDirectory)
            #expect((destinationPath + "subdir_1").exists)
            #expect((destinationPath + "subdir_1/subdir_2").exists)
        }

        @Test
        func sourceNotExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing_moved"))
            try #require(!path.exists)
            try #require(!destinationPath.exists)
            let error = try #require(throws: MoveError.self) {
                try path.move(to: destinationPath)
            }
            #expect(error == .sourceNotExist(path))
        }

        @Test(arguments: [
            ("dir1", "dir2"),
            ("dir1", "dir_empty"),
            ("dir_empty", "dir2"),
            ("dir1/subdir_1/subdir_2/1.txt", "dir2/subdir_1/subdir_2/1.txt"),
        ])
        func destinationAlreadyExists(_ source: String, _ destination: String) async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: source))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: destination))
            try #require(path.exists)
            try #require(destinationPath.exists)
            let error = try #require(throws: MoveError.self) {
                try path.move(to: destinationPath)
            }
            #expect(error == .destinationAlreadyExists(destinationPath))
        }

        @Test
        func destinationNotExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1/subdir_1/subdir_2/1.txt"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing/1.txt"))
            try #require(path.exists)
            try #require(!destinationPath.parent.exists)
            let error = try #require(throws: MoveError.self) {
                try path.move(to: destinationPath)
            }
            #expect(error == .destinationNotExist(destinationPath.parent))
        }
    }

    @Suite
    struct MoveToDirectory {
        @Test
        func file() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test.txt"))
            let directoryPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty/test.txt"))
            try #require(path.exists)
            try #require(path.isFile)
            try #require(!destinationPath.exists)
            #expect(throws: Never.self) {
                try path.move(toDirectory: directoryPath)
            }
            #expect(!path.exists)
            #expect(destinationPath.exists)
            #expect(destinationPath.isFile)
        }

        @Test
        func directory() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            let directoryPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty/dir1"))
            try #require(path.exists)
            try #require(path.isDirectory)
            try #require(!destinationPath.exists)
            #expect(throws: Never.self) {
                try path.move(toDirectory: directoryPath)
            }
            #expect(!path.exists)
            #expect(destinationPath.exists)
            #expect((destinationPath + "subdir_1/subdir_2").exists)
        }

        @Test
        func destinationNotExist() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing"))
            try #require(path.exists)
            try #require(!destinationPath.exists)
            let error = try #require(throws: MoveError.self) {
                try path.move(toDirectory: destinationPath)
            }
            #expect(error == .destinationNotExist(destinationPath))
        }

        @Test
        func notDirectory() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1/subdir_1/subdir_2/1.txt"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir2/subdir_1/subdir_2/1.txt"))
            try #require(destinationPath.exists)
            try #require(destinationPath.isFile)
            let error = try #require(throws: MoveError.self) {
                try path.move(toDirectory: destinationPath)
            }
            #expect(error == .destinationIsNotDirectory(destinationPath))
        }

        @Test
        func destinationAlreadyExists() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1/subdir_1"))
            let directoryPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir2"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir2/subdir_1"))
            try #require(path.exists)
            try #require(directoryPath.exists)
            try #require(destinationPath.exists)
            let error = try #require(throws: MoveError.self) {
                try path.move(toDirectory: directoryPath)
            }
            #expect(error == .destinationAlreadyExists(destinationPath))
        }
    }
}
