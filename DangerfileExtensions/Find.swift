import Foundation

func find(in directory: URL = .currentDirectory(), name pattern: String) -> [URL] {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/find")
    process.arguments = [directory.path, "-name", pattern]

    let pipe = Pipe()
    process.standardOutput = pipe
    do {
        try process.run()
    } catch {
        print("Failed to run find command: \(error)")
        return []
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    let results = output.split(separator: "\n").map { URL(fileURLWithPath: String($0)) }
    return results
}
