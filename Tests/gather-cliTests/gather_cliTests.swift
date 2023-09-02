import class Foundation.Bundle
import XCTest

func gatherWith(args: [String], stdin: String?) -> String? {
    // Some of the APIs that we use below are available in macOS 10.13 and above.
    guard #available(macOS 10.13, *) else {
        return nil
    }

    // Mac Catalyst won't have `Process`, but it is supported for executables.
    #if !targetEnvironment(macCatalyst)
        do {
            let fooBinary = productsDirectory.appendingPathComponent("gather")

            let process = Process()
            process.executableURL = fooBinary

            if stdin != nil {
                let inpipe = Pipe()
                let testString = "<p>Testing gather</p>"
                inpipe.fileHandleForWriting.write(Data(testString.utf8))
                inpipe.fileHandleForWriting.closeFile()
                process.standardInput = inpipe
            }

            let pipe = Pipe()
            process.standardOutput = pipe

            process.arguments = args
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            fatalError("Error running Gather")
        }
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

final class gather_cliTests: XCTestCase {
    func testTitleOnly() throws {
        let args = ["--title-only", "https://github.com/vimtaai/critic-markup"]
        let output = gatherWith(args: args, stdin: nil)
        XCTAssertNotNil(output)
        XCTAssertEqual(output!, "GitHub - vimtaai/critic-markup: CriticMarkup in JavaScript\n")
    }

    func testMetadata() throws {
        let args = ["--metadata", "https://github.com/vimtaai/critic-markup?query=value&something=else#nowhere"]
        let output = gatherWith(args: args, stdin: nil)
        XCTAssertNotNil(output)
        XCTAssertNotNil(output!.range(of: "source: https://github.com/vimtaai/critic-markup\n"))
    }

    func testStdin() throws {
        let args = ["--stdin", "--html", "--no-readability"]
        let testString = "<p>Testing gather</p>"
        let output = gatherWith(args: args, stdin: testString)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "Testing gather\n")
    }

    func testCopyToClipboard() throws {
        let args = ["--copy", "https://forums.swift.org/t/running-launching-an-existing-executable-program-from-swift-on-macos/47653"]
        let output = gatherWith(args: args, stdin: nil)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "Content in clipboard\n")
    }

    func testReadFromClipboard() throws {
        let result = ""
/*
        let result = "[Bullseye][1] has been updated with a couple of tweaks.\n\n\n[1]: /2013/07/30/precise-web-clipping-to-markdown-with-bullseye/\n\nFirst, pressing escape after running the bookmarklet will now cancel it and you can resume browsing without refreshing the page.\n\nNext, if you want to skip the Marky preview frame with copy button, you can make a quick edit to the bookmarklet at the very beginning, adding \`window.bullseyeShowFrame=0;\` after the \`javascript:\` and before the function:\n    \n    \n    javascript:window.bullseyeShowFrame=0;(function()...\n\nCopy\n\nI also made a couple of tweaks to the path builder to help with getting the raw source when it\'s available.\n\nIf you have the bookmarklet installed, it\'s already updated. If you want to switch to getting raw Markdown text back, just make the above edit. If you haven\'t installed it yet, just drag the link below to your bookmarks bar.\n\nIf you run into issues on a particular page, I\'m happy to look at test cases. Just [shoot me an email][2].\n\n\n[2]: http://brettterpstra.com/contact/\n"
*/
        let args = ["--paste", "--html"]
        let output = gatherWith(args: args, stdin: nil)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, result)
    }
/*
    func testReadabilityWithYAMLFrontMatter() throws {
        let args = [
            "--readability",
            "--metadata-yaml",
            "http://localhost:3000/snippet.html",
        ]
        let output = gatherWith(args: args, stdin: nil)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "")
    }
*/
}
