import XCTest
//@testable import JSON
@testable import JSONKit

class JSONTests: XCTestCase {
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
