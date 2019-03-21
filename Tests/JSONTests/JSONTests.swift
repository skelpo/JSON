import XCTest
//@testable import JSON
@testable import JSONKit

class JSONTests: XCTestCase {
    func testAssociatedValueProperties() {
        XCTAssertNil(JSON.string("foo").int)
        XCTAssertNil(JSON.string("foo").null)
        XCTAssertEqual(JSON.string("foo").string, "foo")
        
        XCTAssertNil(JSON.bool(true).string)
        XCTAssertNil(JSON.bool(true).null)
        XCTAssertEqual(JSON.bool(true).bool, true)
        
        XCTAssertNil(JSON.number(.int(42)).bool)
        XCTAssertNil(JSON.number(.int(42)).null)
        XCTAssertEqual(JSON.number(.int(42)).int, 42)
        
        XCTAssertNil(JSON.number(.float(3.14)).int)
        XCTAssertNil(JSON.number(.float(3.14)).null)
        XCTAssertEqual(JSON.number(.float(3.14)).float, 3.14)
        
        XCTAssertNil(JSON.number(.double(1553177913.5623169)).float)
        XCTAssertNil(JSON.number(.double(1553177913.5623169)).null)
        XCTAssertEqual(JSON.number(.double(1553177913.5623169)).double, 1553177913.5623169)
        
        XCTAssertNil(JSON.array([.bool(true), .bool(false), .string("foo")]).object)
        XCTAssertNil(JSON.array([.bool(true), .bool(false), .string("foo")]).null)
        XCTAssertEqual(
            JSON.array([.bool(true), .bool(false), .string("foo")]).array,
            [.bool(true), .bool(false), .string("foo")]
        )
        
        XCTAssertNil(JSON.object(["foo": .string("bar"), "fizz": .bool(true), "buzz": .number(.int(42))]).array)
        XCTAssertNil(JSON.object(["foo": .string("bar"), "fizz": .bool(true), "buzz": .number(.int(42))]).null)
        XCTAssertEqual(
            JSON.object(["foo": .string("bar"), "fizz": .bool(true), "buzz": .number(.int(42))]).object,
            ["foo": .string("bar"), "fizz": .bool(true), "buzz": .number(.int(42))]
        )
        
        XCTAssertNil(JSON.null.bool)
        XCTAssertNil(JSON.null.null)
        XCTAssertNil(JSON.null.string)
    }
    
    func testDynamicAccessGet()throws {
        var weather = try JSON(data: Data(json.utf8))
        XCTAssertEqual(weather.minutely.data.0.time.int, 1517594040)
        
        measure {
            for _ in 0..<10_000 {
                _ = weather.minutely.data.0.time
            }
        }
    }
    
    func testDynamicAccessSetSpeed()throws {
        var weather = try JSON(data: Data(json.utf8))
        
        weather.minutely.data.0.time.int = 1517594031
        XCTAssertEqual(weather.minutely.data.0.time.int, 1517594031)
        
        weather.minutely.data.10.time = 42
        XCTAssertEqual(weather.minutely.data.10.time, 42)
        
        measure {
            for _ in 0..<10_000 {
                weather.minutely.data.time = 39916800
            }
        }
    }
}
