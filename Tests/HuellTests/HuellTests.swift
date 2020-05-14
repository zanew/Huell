import XCTest
@testable import Huell

final class HuellTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Huell().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
