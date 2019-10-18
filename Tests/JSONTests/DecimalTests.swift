import XCTest
import JSON

final class DecimalTests: XCTestCase {
    func testDecimalEncode() throws {
        let json = try Decimal(3.14).json()
        print(json)
    }
}
