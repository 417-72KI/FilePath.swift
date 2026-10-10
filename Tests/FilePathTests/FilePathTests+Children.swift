import Foundation
import Testing
@testable import FilePath

extension FilePathTests {
    @Suite
    struct Children {
        @Test(arguments: [
            ("dir1", ["dir1/subdir_1/"]),
            ("dir1/subdir_1", ["dir1/subdir_1/subdir_2/"]),
            ("dir1/subdir_1/subdir_2", ["dir1/subdir_1/subdir_2/1.txt", "dir1/subdir_1/subdir_2/2.txt", "dir1/subdir_1/subdir_2/3.txt", "dir1/subdir_1/subdir_2/4.txt", "dir1/subdir_1/subdir_2/5.txt"]),
        ])
        func normal(_ path: String, _ expected: [String]) async throws {
            let rootPath = FilePath(url: UsingTemporaryDirectory.current)
            let path = rootPath + path
            let expected = expected.map { rootPath + $0 }.sorted()
            let children = try path.children.sorted()
            #expect(children.map { $0.url.resolvingSymlinksInPath() } == expected.map { $0.url.resolvingSymlinksInPath() })
        }

        @Test
        func notExist() async throws {
            let rootPath = FilePath(url: UsingTemporaryDirectory.current)
            let path = rootPath + "not_existing"
            try #require(!path.exists)
            let error = try #require(throws: FileStateError.self) {
                _ = try path.children
            }
            #expect(error == .notExist(path))
        }

        @Test
        func notDirectory() async throws {
            let rootPath = FilePath(url: UsingTemporaryDirectory.current)
            let path = rootPath + "dir1/subdir_1/subdir_2/1.txt"
            try #require(path.exists)
            try #require(path.isFile)
            let error = try #require(throws: FileStateError.self) {
                _ = try path.children
            }
            #expect(error == .notDirectory(path))
        }
    }
}
