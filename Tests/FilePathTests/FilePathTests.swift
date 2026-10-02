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

    @Test(arguments: [
        ("foo/bar", "foo/"),
        ("~/foo/bar", "~/foo/"),
        ("/foo/bar", "/foo/"),
        ("/foo/", "/"),
        ("/", "/"),
    ])
    func parent(_ path: FilePath, _ expected: FilePath) async throws {
        #expect(path.parent == expected)
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
}
