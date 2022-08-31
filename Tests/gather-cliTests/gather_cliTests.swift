import class Foundation.Bundle
import XCTest

final class gather_cliTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        // Mac Catalyst won't have `Process`, but it is supported for executables.
        #if !targetEnvironment(macCatalyst)

            let fooBinary = productsDirectory.appendingPathComponent("gather")

            let process = Process()
            process.executableURL = fooBinary

            let args = ["--stdin", "--html", "--no-readability"]

            let inpipe = Pipe()
            let testString = "<p>Testing gather</p>"
            inpipe.fileHandleForWriting.write(Data(testString.utf8))
            inpipe.fileHandleForWriting.closeFile()
            process.standardInput = inpipe

            let pipe = Pipe()
            process.standardOutput = pipe

            process.arguments = args
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)

            XCTAssertEqual(output, "Testing gather\n")
        #endif
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
            for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                return bundle.bundleURL.deletingLastPathComponent()
            }
            fatalError("couldn't find the products directory")
        #else
            return Bundle.main.bundleURL
        #endif
    }
}
