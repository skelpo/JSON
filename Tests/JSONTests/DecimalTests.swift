import XCTest
import JSON

final class DecimalTests: XCTestCase {
    func testDecimalEncode() throws {
        let decJSON = try Decimal(3.14).json()
        let numJSON = try Num(value: 3.14).json()

        XCTAssertEqual(decJSON, .number(.decimal(3.14)))
        XCTAssertEqual(numJSON, .object(["value": .number(.decimal(3.14))]))
    }

    func testDecimalDecode() throws {
        let decJSON = try Decimal(3.14).json()
        let numJSON = try Num(value: 3.14).json()

        let dec = try JSONCoder.decode(Decimal.self, from: decJSON)
        let num = try Num(json: numJSON)

        XCTAssertEqual(dec, 3.14)
        XCTAssertEqual(num, Num(value: 3.14))
    }
}

fileprivate struct Num: Codable, Equatable {
    var value: Decimal
}
