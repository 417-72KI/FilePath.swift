import Foundation
import Testing
@testable import FilePath

@Suite(.usingTemporaryDirectory)
struct FilePathTests {
    @Test(arguments: [
        "foo/bar",
        "foo/bar/../baz",
        "../foo/bar/baz",
    ])
    func relativePath(_ path: String) async throws {
        let expectedURL = URL(
            filePath: path,
            relativeTo: .currentDirectory()
        )
        let path = await FilePath(path)
        #expect(await path.url == expectedURL)
        #expect(path.path == expectedURL.path())
        #expect(path.absolutePath == expectedURL.absoluteURL.path())
    }

    @Test(arguments: [
        "/foo/bar",
        "/foo/bar/../baz",
        "~/foo/bar/baz",
    ])
    func absolutePath(_ path: String) async throws {
        let expectedURL = URL(filePath: path)
        let path = await FilePath(path)
        #expect(await path.url == expectedURL)
        #expect(path.path == expectedURL.path())
        #expect(path.absolutePath == expectedURL.absoluteURL.path())
    }

    @Test
    func current() async throws {
        let fm = FileManager.default
        #expect(await FilePath.current == FilePath(fm.currentDirectoryPath))
    }

    @Test
    func home() async throws {
        let fm = FileManager.default
        #if os(iOS) || os(tvOS) || os(watchOS)
        #expect(FilePath.home == FilePath("~/"))
        #else
        #expect(await FilePath.home == FilePath(fm.homeDirectoryForCurrentUser.path()))
        #endif
    }

    @Suite
    struct PlusOperator {
        let basePath = FilePath("foo/bar")

        @Test
        func appendingPath() async throws {
            #expect(basePath + "baz/qux" == FilePath("foo/bar/baz/qux"))
            #expect(basePath + "baz" + "qux" == FilePath("foo/bar/baz/qux"))
        }

        @Test
        func appendingPathWithDotDot() async throws {
            #expect(basePath + "../baz/qux" == FilePath("foo/baz/qux"))
            #expect(basePath + "../baz" + "qux" == FilePath("foo/baz/qux"))
            #expect(basePath + ".." + "baz/qux" == FilePath("foo/baz/qux"))
            #expect(basePath + ".." + "baz" + "qux" == FilePath("foo/baz/qux"))
        }
    }

    @Suite
    struct ExpressibleByStringLiteral {
        @Test
        func relativePath() async throws {
            let expectedURL = URL(
                filePath: "foo/bar",
                relativeTo: .currentDirectory()
            )
            let path: FilePath = "foo/bar"
            #expect(path.path == expectedURL.path())
        }

        @Test
        func absolutePath() async throws {
            let expectedURL = URL(filePath: "/foo/bar")
            let path: FilePath = "/foo/bar"
            #expect(path.path == expectedURL.path())
        }
    }

    @Suite
    struct Exists {
        @Test
        func file() async throws {
            let fileURL = UsingTemporaryDirectory.current.appending(path: "test.txt")
            let path = FilePath(url: fileURL)
            #expect(await path.exists)
            #expect(await path.isFile)
            #expect(await !path.isDirectory)
        }

        @Test
        func directory() async throws {
            let fileURL = UsingTemporaryDirectory.current.appending(path: "dir1")
            let path = FilePath(url: fileURL)
            #expect(await path.exists)
            #expect(await !path.isFile)
            #expect(await path.isDirectory)
        }
    }

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
            let error = try await #require(throws: NSError.self) {
                try await path.move(to: destinationPath)
            }
            #expect(error.domain == NSCocoaErrorDomain)
            #expect(error.code == 4)
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
            let error = try await #require(throws: NSError.self) {
                try await path.move(to: destinationPath)
            }
            #expect(error.domain == NSCocoaErrorDomain)
            #expect(error.code == 516)
        }
    }
}
