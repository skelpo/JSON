import XCTest
import JSON

struct DData: Codable {
    var d1: Decimal
    var d2: Decimal
}

final class DecimalTests: XCTestCase {
    
    var testJson = """
{"d2":"1.1234","d1":"3.14"}
"""
    
    func testDecimalEncode() throws {
        let decJSON = try Decimal(3.14).json()
        let numJSON = try Num(value: 3.14).json()

        XCTAssertEqual(decJSON, .string("3.14"))
        XCTAssertEqual(numJSON, .object(["value": .string("3.14")]))
    }

    func testDecimalDecode() throws {
        let decJSON = try Decimal(3.14).json()
        let numJSON = try Num(value: 3.14).json()

        let dec = try JSONCoder.decode(Decimal.self, from: decJSON)
        let num = try Num(json: numJSON)

        XCTAssertEqual(dec, 3.14)
        XCTAssertEqual(num, Num(value: 3.14))
    }
    
    func testStringDecoding() throws {
        let json = try JSON(data: testJson.data(using: .utf8)!)
        let dd = try JSONCoder.decode(DData.self, from: json)
        
        XCTAssertEqual(dd.d1,3.14)
        XCTAssertEqual(dd.d2,1.1234)
    }
    
    func testStringEncoding() throws {
        let dd = DData(d1: 3.14, d2: 1.1234)
        
        let json = try JSONCoder.encode(dd)
        let stringData = try JSONEncoder().encode(json)
        let string = String(data: stringData, encoding: .utf8)!
        
        XCTAssertEqual(testJson, string)
    }
}

fileprivate struct Num: Codable, Equatable {
    var value: Decimal
}
