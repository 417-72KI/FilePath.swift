import Foundation

extension Process {
    @discardableResult
    static func run(_ executableURL: URL, with arguments: [String] = []) throws -> String {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    @discardableResult
    static func run(_ executablePath: String, with arguments: [String] = []) throws -> String {
        try run(URL(filePath: executablePath), with: arguments)
    }
}
