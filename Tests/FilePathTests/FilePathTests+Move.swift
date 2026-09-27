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
            try #require(await path.exists)
            try #require(await path.isFile)
            try #require(await !destinationPath.exists)
            try await path.move(to: destinationPath)
            #expect(await !path.exists)
            #expect(await destinationPath.exists)
            #expect(await destinationPath.isFile)
        }

        @Test
        func directory() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1_moved"))
            try #require(await path.exists)
            try #require(await path.isDirectory)
            try #require(await !destinationPath.exists)
            try await path.move(to: destinationPath)
            #expect(await !path.exists)
            #expect(await destinationPath.exists)
            #expect(await destinationPath.isDirectory)
            #expect(await (destinationPath + "subdir_1").exists)
            #expect(await (destinationPath + "subdir_1/subdir_2").exists)
        }

        @Test
        func notExisting() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "not_existing_moved"))
            try #require(await !path.exists)
            try #require(await !destinationPath.exists)
            let error = try await #require(throws: FilePathError.self) {
                try await path.move(to: destinationPath)
            }
            #expect(error == .notExists(path))
        }

        @Test(arguments: [
            ("dir1", "dir2"),
            ("dir1", "dir_empty"),
            ("dir_empty", "dir2"),
            ("dir1/subdir_1/subdir_2/1.txt", "dir2/subdir_1/subdir_2/1.txt"),
        ])
        func conflict(_ source: String, _ destination: String) async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: source))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: destination))
            try #require(await path.exists)
            try #require(await destinationPath.exists)
            let error = try await #require(throws: FilePathError.self) {
                try await path.move(to: destinationPath)
            }
            #expect(error == .conflict(path, destinationPath))
        }
    }

    @Suite
    struct MoveToDirectory {
        @Test
        func file() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "test.txt"))
            let directoryPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty/test.txt"))
            try #require(await path.exists)
            try #require(await path.isFile)
            try #require(await !destinationPath.exists)
            await #expect(throws: Never.self) {
                try await path.move(toDirectory: directoryPath)
            }
            #expect(await !path.exists)
            #expect(await destinationPath.exists)
            #expect(await destinationPath.isFile)
        }

        @Test
        func directory() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1"))
            let directoryPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir_empty/dir1"))
            try #require(await path.exists)
            try #require(await path.isDirectory)
            try #require(await !destinationPath.exists)
            await #expect(throws: Never.self) {
                try await path.move(toDirectory: directoryPath)
            }
            #expect(await !path.exists)
            #expect(await destinationPath.exists)
            #expect(await (destinationPath + "subdir_1/subdir_2").exists)
        }

        @Test
        func notDirectory() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1/subdir_1/subdir_2/1.txt"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir2/subdir_1/subdir_2/1.txt"))
            try #require(await destinationPath.exists)
            try #require(await destinationPath.isFile)
            let error = try await #require(throws: FilePathError.self) {
                try await path.move(toDirectory: destinationPath)
            }
            #expect(error == .notDirectory(destinationPath))
        }

        @Test
        func conflict() async throws {
            let path = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir1/subdir_1"))
            let directoryPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir2"))
            let destinationPath = FilePath(url: UsingTemporaryDirectory.current.appending(path: "dir2/subdir_1"))
            try #require(await path.exists)
            try #require(await directoryPath.exists)
            try #require(await destinationPath.exists)
            let error = try await #require(throws: FilePathError.self) {
                try await path.move(to: destinationPath)
            }
            #expect(error == .conflict(path, destinationPath))
        }
    }
}
