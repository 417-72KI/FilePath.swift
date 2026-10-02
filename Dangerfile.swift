import Danger
import Foundation

// fileImport: DangerfileExtensions/Find.swift
// fileImport: DangerfileExtensions/TestResult.swift

let danger = Danger()

SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Sources"), inline: true)

let git = danger.git

if git.modifiedFiles.contains("LICENSE") {
    danger.fail("Do not modify LICENSE !!")
}

if git.deletedFiles.contains("LICENSE") {
    danger.fail("Do not delete LICENSE !!")
}

if let github = danger.github {
    if github.pullRequest.title.lowercased().contains("[wip]") {
        danger.warn("PR is classed as Work in Progress")
    }
}

let testResultJSON = (ProcessInfo.processInfo.environment["GITHUB_WORKSPACE"]
    .flatMap { URL.init(filePath: $0) } ?? .currentDirectory())
    .appending(path: "test_output/result.json")
print(testResultJSON.absoluteURL)
if FileManager.default.fileExists(atPath: testResultJSON.path()) {
    let testResult = try TestResult.from(jsonFile: testResultJSON)
    if testResult.isAllPassed {
        danger.message("All tests passed successfully.")
    } else {
        danger.fail("Some tests failed. Please check the test results.")
    }
} else {
    danger.warn("Test result file not found at \(testResultJSON.path())")
}
