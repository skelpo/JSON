import XCTest
import JSON
import Foundation

final class JSONCodingTests: XCTestCase {
    private var userJSON: JSON = [
        "isAdmin": false,
        "age": 17,
        "firstname": "Caleb",
        "lastname": "Kleveter",
        "username": "caleb_kleveter",
        "password": "fizzbuzzfoobar",
        "favorites": ["Orange", "Blue"],
        "relatives": ["Father", "Mother", "Sister", "Brother"]
    ]

    private let user = User(
        username: "caleb_kleveter", lastname: "Kleveter", firstname: "Caleb", age: 17, password: "fizzbuzzfoobar", isAdmin: false, favorites: ["Orange", "Blue"],
        relatives: ["Father", "Mother", "Sister", "Brother"]
    )

    func testUserJSONDecoding()throws {
        let user = try self.intialize(User.self, with: self.userJSON)

        XCTAssertEqual(user.isAdmin, userJSON.isAdmin.bool)
        XCTAssertEqual(user.age, userJSON.age.int)
        XCTAssertEqual(user.firstname, userJSON.firstname.string)
        XCTAssertEqual(user.lastname, userJSON.lastname.string)
        XCTAssertEqual(user.username, userJSON.username.string)
        XCTAssertEqual(user.password, userJSON.password.string)
        XCTAssertEqual(user.favorites, Set(userJSON.favorites.array?.compactMap { $0.string } ?? []))
        XCTAssertEqual(user.relatives, userJSON.relatives.array?.compactMap { $0.string })
    }

    func testUserJSONEncoding()throws {
        let json = try JSONCoder.encode(user)

        XCTAssertEqual(json.isAdmin.bool, user.isAdmin)
        XCTAssertEqual(json.age.int, user.age)
        XCTAssertEqual(json.firstname.string, user.firstname)
        XCTAssertEqual(json.lastname.string, user.lastname)
        XCTAssertEqual(json.username.string, user.username)
        XCTAssertEqual(json.password.string, user.password)
        XCTAssertEqual(Set(json.favorites.array?.compactMap { $0.string } ?? []), user.favorites)
        XCTAssertEqual(json.relatives.array?.compactMap { $0.string }, user.relatives)
    }

    func testJSONDecoding()throws {
        let data = json.data(using: .utf8)!
        let j = try JSONDecoder().decode(JSON.self, from: data)
        
        switch j {
        case .null, .string, .number, .bool, .array: XCTFail()
        case let .object(structure): XCTAssert(!structure.isEmpty)
        }
    }
    
    func testJSONEncoding()throws {
        let data = json.data(using: .utf8)!
        let j = try JSONDecoder().decode(JSON.self, from: data)
        
        let encoder = JSONEncoder()
        let result = try encoder.encode(j)
        let string = String(data: result, encoding: .utf8)
        
        XCTAssert(string != nil)
    }
    
    func testDecodingSpeed() {
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        measure {
            do {
                _ = try decoder.decode(JSON.self, from: data)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testEncodingSpeed()throws {
        let data = json.data(using: .utf8)!
        let j = try JSONDecoder().decode(JSON.self, from: data)
        let encoder = JSONEncoder()
        
        
        measure {
            do {
                _ = try encoder.encode(j)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testToJSON() {
        measure {
            do {
                _ = try self.user.json()
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testFromJSON() {
        measure {
            do {
                _ = try User(json: userJSON)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testEncodingNestedJSON() {
        do {
            let data = json.data(using: .utf8)!
            let weather = try JSONDecoder().decode(WeatherData.self, from: data)
            _ = try JSONCoder.encode(weather)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testEncodeNestedJSONSpeed() {
        let data = json.data(using: .utf8)!
        let weather = try! JSONDecoder().decode(WeatherData.self, from: data)
        
        measure {
            do {
                _ = try JSONCoder.encode(weather)
            } catch let error {
                XCTFail("\n\(error)\n")
            }
        }
    }

    func testDecodeNested() throws {
        let data = nestedJSON.data(using: .utf8)!
        let user = try JSONDecoder().decode(NestedUser.self, from: data)

        XCTAssertEqual(user, NestedUser.default)
    }

    @available(OSX 10.13, *)
    func testEncodeNested() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(NestedUser.default)
        XCTAssertEqual(String(decoding: data, as: UTF8.self), nestedJSON)
    }

    func testDecodingNestedJSON() {
        do {
            let data = json.data(using: .utf8)!
            let j = try JSON(data: data)
            _ = try JSONCoder.decode(WeatherData.self, from: j)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testDecodeNestedJSONSpeed() {
        let data = json.data(using: .utf8)!
        let j = try! JSON(data: data)
        
        measure {
            do {
                _ = try JSONCoder.decode(WeatherData.self, from: j)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testDefaultJSONEncoding() {
        let weather = try! JSONDecoder().decode(WeatherData.self, from: json.data(using: .utf8)!)
        
        measure {
            do {
                _ = try JSONEncoder().encode(weather)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testDefaultJSONEDecoding() {
        measure {
            do {
                _ = try JSONDecoder().decode(WeatherData.self, from: json.data(using: .utf8)!)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testSmallData() {
        do {
            let json = try JSON(data: smallData.data(using: .utf8)!)
            let number = json["number"]
            let int = Int(json: number)
            XCTAssert(int == 23)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testFailableJSONSpeed() {
        measure {
            do {
                for _ in 0...10_000 {
                    _ = try 42.failableJSON()
                }
            } catch let error {
                print("\(error)")
            }
        }
    }
    
    func testJSONInitJSON()throws {
        let json: JSON = [
            "key": "value",
            "k": 1,
            "l": [true, true, false]
        ]
        
        _ = JSON(json: json)
        _ = try self.intialize(JSON.self, with: json)
    }
    
    func testSingleValueEncodingFailure()throws {
        struct SingleDouble: Codable {
            let id: Int
            let name: String
            
            init(id: Int, name: String) {
                self.id = id
                self.name = name
            }
            
            init(from decoder: Decoder)throws {
                let container = try decoder.singleValueContainer()
                
                self.id = try container.decode(Int.self)
                self.name = "same ol'"
            }
            
            func encode(to encoder: Encoder)throws {
                var container = encoder.singleValueContainer()
                try container.encode(id)
            }
        }
        
        let subject = SingleDouble(id: 42, name: "The Answer")
        let json = try subject.json()
        
        XCTAssertEqual(json, JSON.number(.int(42)))
        
        let decoded = try SingleDouble(json: json)
        
        XCTAssertEqual(decoded.id, 42)
        XCTAssertEqual(decoded.name, "same ol'")
    }
    
    func testCodingUIntAsSingleValue() throws {
        struct Test: Codable {
            let value: UInt
            init(value: UInt) {
                self.value = value
            }
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.value = try container.decode(UInt.self)
            }
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(self.value)
            }
        }
        
        let signed = Int.random(in: (Int.min ... Int.max))
        let unsigned: UInt = .init(bitPattern: signed)
        let subject = Test(value: unsigned)
        let json = try JSONCoder.encode(subject)
        
        XCTAssertEqual(json.int, Int(bitPattern: subject.value))
        
        let decoded = try JSONCoder.decode(Test.self, from: json)
        
        XCTAssertEqual(decoded.value, subject.value)
    }
    
    // MARK: - Helpers
    
    func intialize<T>(_ type: T.Type, with json: JSON)throws -> T where T: Decodable {
        return try T(json: json)
    }
}

fileprivate struct User: Codable {
    let username: String
    let lastname: String
    let firstname: String
    let age: Int
    let password: String
    let isAdmin: Bool
    let favorites: Set<String>
    let relatives: [String]
}

let smallData = """
{
"number": 23
}
"""

let json = """
{"latitude":37.8267,"longitude":-122.4233,"timezone":"America/Los_Angeles","currently":{"time":1517594062,"summary":"Clear","icon":"clear-day","nearestStormDistance":225,"nearestStormBearing":355,"precipIntensity":0,"precipProbability":0,"temperature":57.31,"apparentTemperature":57.31,"dewPoint":47.98,"humidity":0.71,"pressure":1022.31,"windSpeed":3.03,"windGust":7.69,"windBearing":5,"cloudCover":0.12,"uvIndex":2,"visibility":10,"ozone":295.33},"minutely":{"summary":"Clear for the hour.","icon":"clear-day","data":[{"time":1517594040,"precipIntensity":0,"precipProbability":0},{"time":1517594100,"precipIntensity":0,"precipProbability":0},{"time":1517594160,"precipIntensity":0,"precipProbability":0},{"time":1517594220,"precipIntensity":0,"precipProbability":0},{"time":1517594280,"precipIntensity":0,"precipProbability":0},{"time":1517594340,"precipIntensity":0,"precipProbability":0},{"time":1517594400,"precipIntensity":0,"precipProbability":0},{"time":1517594460,"precipIntensity":0,"precipProbability":0},{"time":1517594520,"precipIntensity":0,"precipProbability":0},{"time":1517594580,"precipIntensity":0,"precipProbability":0},{"time":1517594640,"precipIntensity":0,"precipProbability":0},{"time":1517594700,"precipIntensity":0,"precipProbability":0},{"time":1517594760,"precipIntensity":0,"precipProbability":0},{"time":1517594820,"precipIntensity":0,"precipProbability":0},{"time":1517594880,"precipIntensity":0,"precipProbability":0},{"time":1517594940,"precipIntensity":0,"precipProbability":0},{"time":1517595000,"precipIntensity":0,"precipProbability":0},{"time":1517595060,"precipIntensity":0,"precipProbability":0},{"time":1517595120,"precipIntensity":0,"precipProbability":0},{"time":1517595180,"precipIntensity":0,"precipProbability":0},{"time":1517595240,"precipIntensity":0,"precipProbability":0},{"time":1517595300,"precipIntensity":0,"precipProbability":0},{"time":1517595360,"precipIntensity":0,"precipProbability":0},{"time":1517595420,"precipIntensity":0,"precipProbability":0},{"time":1517595480,"precipIntensity":0,"precipProbability":0},{"time":1517595540,"precipIntensity":0,"precipProbability":0},{"time":1517595600,"precipIntensity":0,"precipProbability":0},{"time":1517595660,"precipIntensity":0,"precipProbability":0},{"time":1517595720,"precipIntensity":0,"precipProbability":0},{"time":1517595780,"precipIntensity":0,"precipProbability":0},{"time":1517595840,"precipIntensity":0,"precipProbability":0},{"time":1517595900,"precipIntensity":0,"precipProbability":0},{"time":1517595960,"precipIntensity":0,"precipProbability":0},{"time":1517596020,"precipIntensity":0,"precipProbability":0},{"time":1517596080,"precipIntensity":0,"precipProbability":0},{"time":1517596140,"precipIntensity":0,"precipProbability":0},{"time":1517596200,"precipIntensity":0,"precipProbability":0},{"time":1517596260,"precipIntensity":0,"precipProbability":0},{"time":1517596320,"precipIntensity":0,"precipProbability":0},{"time":1517596380,"precipIntensity":0,"precipProbability":0},{"time":1517596440,"precipIntensity":0,"precipProbability":0},{"time":1517596500,"precipIntensity":0,"precipProbability":0},{"time":1517596560,"precipIntensity":0,"precipProbability":0},{"time":1517596620,"precipIntensity":0,"precipProbability":0},{"time":1517596680,"precipIntensity":0,"precipProbability":0},{"time":1517596740,"precipIntensity":0,"precipProbability":0},{"time":1517596800,"precipIntensity":0,"precipProbability":0},{"time":1517596860,"precipIntensity":0,"precipProbability":0},{"time":1517596920,"precipIntensity":0,"precipProbability":0},{"time":1517596980,"precipIntensity":0,"precipProbability":0},{"time":1517597040,"precipIntensity":0,"precipProbability":0},{"time":1517597100,"precipIntensity":0,"precipProbability":0},{"time":1517597160,"precipIntensity":0,"precipProbability":0},{"time":1517597220,"precipIntensity":0,"precipProbability":0},{"time":1517597280,"precipIntensity":0,"precipProbability":0},{"time":1517597340,"precipIntensity":0,"precipProbability":0},{"time":1517597400,"precipIntensity":0,"precipProbability":0},{"time":1517597460,"precipIntensity":0,"precipProbability":0},{"time":1517597520,"precipIntensity":0,"precipProbability":0},{"time":1517597580,"precipIntensity":0,"precipProbability":0},{"time":1517597640,"precipIntensity":0,"precipProbability":0}]},"hourly":{"summary":"Clear throughout the day.","icon":"clear-day","data":[{"time":1517590800,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":55.29,"apparentTemperature":55.29,"dewPoint":47.53,"humidity":0.75,"pressure":1022.13,"windSpeed":2.65,"windGust":5.19,"windBearing":353,"cloudCover":0.09,"uvIndex":1,"visibility":10,"ozone":294.52},{"time":1517594400,"summary":"Clear","icon":"clear-day","precipIntensity":0.0003,"precipProbability":0.04,"precipType":"rain","temperature":57.52,"apparentTemperature":57.52,"dewPoint":48.02,"humidity":0.71,"pressure":1022.33,"windSpeed":3.08,"windGust":7.95,"windBearing":6,"cloudCover":0.12,"uvIndex":2,"visibility":10,"ozone":295.41},{"time":1517598000,"summary":"Clear","icon":"clear-day","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":59.98,"apparentTemperature":59.98,"dewPoint":48.68,"humidity":0.66,"pressure":1021.8,"windSpeed":4.2,"windGust":11.06,"windBearing":14,"cloudCover":0.16,"uvIndex":2,"visibility":10,"ozone":296.43},{"time":1517601600,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":62.77,"apparentTemperature":62.77,"dewPoint":49.14,"humidity":0.61,"pressure":1021.07,"windSpeed":5.36,"windGust":13.14,"windBearing":23,"cloudCover":0.2,"uvIndex":3,"visibility":10,"ozone":297.55},{"time":1517605200,"summary":"Partly Cloudy","icon":"partly-cloudy-day","precipIntensity":0.0001,"precipProbability":0.01,"precipType":"rain","temperature":64.83,"apparentTemperature":64.83,"dewPoint":49.65,"humidity":0.58,"pressure":1020.4,"windSpeed":5.62,"windGust":11.9,"windBearing":20,"cloudCover":0.28,"uvIndex":3,"visibility":10,"ozone":299.02},{"time":1517608800,"summary":"Clear","icon":"clear-day","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":67.3,"apparentTemperature":67.3,"dewPoint":50.46,"humidity":0.55,"pressure":1020.35,"windSpeed":5.32,"windGust":11.76,"windBearing":11,"cloudCover":0.18,"uvIndex":2,"visibility":10,"ozone":301.19},{"time":1517612400,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":68.7,"apparentTemperature":68.7,"dewPoint":50.93,"humidity":0.53,"pressure":1020.3,"windSpeed":4.71,"windGust":9.26,"windBearing":358,"cloudCover":0.24,"uvIndex":1,"visibility":10,"ozone":303.66},{"time":1517616000,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":69.37,"apparentTemperature":69.37,"dewPoint":51.3,"humidity":0.53,"pressure":1020.28,"windSpeed":4.19,"windGust":7.66,"windBearing":353,"cloudCover":0.21,"uvIndex":1,"visibility":10,"ozone":305.45},{"time":1517619600,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":67.83,"apparentTemperature":67.83,"dewPoint":52.18,"humidity":0.57,"pressure":1019.99,"windSpeed":3.59,"windGust":4.96,"windBearing":6,"cloudCover":0.14,"uvIndex":0,"visibility":10,"ozone":305.97},{"time":1517623200,"summary":"Clear","icon":"clear-night","precipIntensity":0.0001,"precipProbability":0.01,"precipType":"rain","temperature":66.05,"apparentTemperature":66.05,"dewPoint":50.95,"humidity":0.58,"pressure":1019.62,"windSpeed":3.69,"windGust":4.3,"windBearing":17,"cloudCover":0.15,"uvIndex":0,"visibility":10,"ozone":305.89},{"time":1517626800,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0,"precipProbability":0,"temperature":63.52,"apparentTemperature":63.52,"dewPoint":50.9,"humidity":0.63,"pressure":1019.7,"windSpeed":3.56,"windGust":3.88,"windBearing":25,"cloudCover":0.33,"uvIndex":0,"visibility":10,"ozone":305.93},{"time":1517630400,"summary":"Clear","icon":"clear-night","precipIntensity":0.0001,"precipProbability":0.01,"precipType":"rain","temperature":63.11,"apparentTemperature":63.11,"dewPoint":50.19,"humidity":0.63,"pressure":1019.8,"windSpeed":3.59,"windGust":3.75,"windBearing":22,"cloudCover":0.1,"uvIndex":0,"visibility":10,"ozone":306.82},{"time":1517634000,"summary":"Clear","icon":"clear-night","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":61.29,"apparentTemperature":61.29,"dewPoint":49.98,"humidity":0.66,"pressure":1020.48,"windSpeed":3.18,"windGust":4.21,"windBearing":16,"cloudCover":0.06,"uvIndex":0,"visibility":10,"ozone":307.79},{"time":1517637600,"summary":"Clear","icon":"clear-night","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":61.08,"apparentTemperature":61.08,"dewPoint":49.25,"humidity":0.65,"pressure":1020.8,"windSpeed":3.29,"windGust":4.26,"windBearing":19,"cloudCover":0.05,"uvIndex":0,"visibility":10,"ozone":308.04},{"time":1517641200,"summary":"Clear","icon":"clear-night","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":59.99,"apparentTemperature":59.99,"dewPoint":49,"humidity":0.67,"pressure":1020.9,"windSpeed":3.48,"windGust":3.73,"windBearing":11,"cloudCover":0.04,"uvIndex":0,"visibility":10,"ozone":306.95},{"time":1517644800,"summary":"Clear","icon":"clear-night","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":58.93,"apparentTemperature":58.93,"dewPoint":48.37,"humidity":0.68,"pressure":1020.68,"windSpeed":3.73,"windGust":3.81,"windBearing":25,"cloudCover":0.02,"uvIndex":0,"visibility":10,"ozone":305.03},{"time":1517648400,"summary":"Clear","icon":"clear-night","precipIntensity":0,"precipProbability":0,"temperature":58.12,"apparentTemperature":58.12,"dewPoint":47.69,"humidity":0.68,"pressure":1020.51,"windSpeed":3.92,"windGust":3.94,"windBearing":36,"cloudCover":0.01,"uvIndex":0,"visibility":10,"ozone":302.61},{"time":1517652000,"summary":"Clear","icon":"clear-night","precipIntensity":0,"precipProbability":0,"temperature":57.73,"apparentTemperature":57.73,"dewPoint":46.91,"humidity":0.67,"pressure":1020.42,"windSpeed":4.06,"windGust":4.07,"windBearing":45,"cloudCover":0.01,"uvIndex":0,"visibility":10,"ozone":299.69},{"time":1517655600,"summary":"Clear","icon":"clear-night","precipIntensity":0,"precipProbability":0,"temperature":57.57,"apparentTemperature":57.57,"dewPoint":46.1,"humidity":0.66,"pressure":1020.37,"windSpeed":4.16,"windGust":4.5,"windBearing":54,"cloudCover":0.01,"uvIndex":0,"visibility":10,"ozone":296.28},{"time":1517659200,"summary":"Clear","icon":"clear-night","precipIntensity":0,"precipProbability":0,"temperature":57.43,"apparentTemperature":57.43,"dewPoint":45.41,"humidity":0.64,"pressure":1020.38,"windSpeed":4.21,"windGust":4.91,"windBearing":60,"cloudCover":0.01,"uvIndex":0,"visibility":10,"ozone":293.4},{"time":1517662800,"summary":"Clear","icon":"clear-night","precipIntensity":0,"precipProbability":0,"temperature":56.82,"apparentTemperature":56.82,"dewPoint":44.79,"humidity":0.64,"pressure":1020.53,"windSpeed":4.23,"windGust":5.07,"windBearing":60,"cloudCover":0.01,"uvIndex":0,"visibility":10,"ozone":291.49},{"time":1517666400,"summary":"Clear","icon":"clear-night","precipIntensity":0,"precipProbability":0,"temperature":56.08,"apparentTemperature":56.08,"dewPoint":44.29,"humidity":0.65,"pressure":1020.77,"windSpeed":4.24,"windGust":5.17,"windBearing":58,"cloudCover":0.01,"uvIndex":0,"visibility":10,"ozone":290.2},{"time":1517670000,"summary":"Clear","icon":"clear-night","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":56.18,"apparentTemperature":56.18,"dewPoint":44.11,"humidity":0.64,"pressure":1021.02,"windSpeed":4.32,"windGust":5.61,"windBearing":55,"cloudCover":0.01,"uvIndex":0,"visibility":10,"ozone":289.11},{"time":1517673600,"summary":"Clear","icon":"clear-day","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":57.74,"apparentTemperature":57.74,"dewPoint":44.45,"humidity":0.61,"pressure":1021.39,"windSpeed":4.5,"windGust":6.7,"windBearing":52,"cloudCover":0.02,"uvIndex":0,"visibility":10,"ozone":288.2},{"time":1517677200,"summary":"Clear","icon":"clear-day","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":59.92,"apparentTemperature":59.92,"dewPoint":45.14,"humidity":0.58,"pressure":1021.77,"windSpeed":4.76,"windGust":8.17,"windBearing":48,"cloudCover":0.03,"uvIndex":1,"visibility":10,"ozone":287.5},{"time":1517680800,"summary":"Clear","icon":"clear-day","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":61.61,"apparentTemperature":61.61,"dewPoint":45.85,"humidity":0.56,"pressure":1021.96,"windSpeed":5.07,"windGust":9.54,"windBearing":45,"cloudCover":0.04,"uvIndex":2,"visibility":10,"ozone":287.15},{"time":1517684400,"summary":"Clear","icon":"clear-day","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":62.86,"apparentTemperature":62.86,"dewPoint":46.5,"humidity":0.55,"pressure":1021.79,"windSpeed":5.55,"windGust":10.86,"windBearing":42,"cloudCover":0.05,"uvIndex":3,"visibility":10,"ozone":287.17},{"time":1517688000,"summary":"Clear","icon":"clear-day","precipIntensity":0.0001,"precipProbability":0.01,"precipType":"rain","temperature":64.24,"apparentTemperature":64.24,"dewPoint":47.15,"humidity":0.54,"pressure":1021.43,"windSpeed":6.13,"windGust":12.12,"windBearing":39,"cloudCover":0.05,"uvIndex":3,"visibility":10,"ozone":287.57},{"time":1517691600,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":66.11,"apparentTemperature":66.11,"dewPoint":47.76,"humidity":0.52,"pressure":1020.97,"windSpeed":6.45,"windGust":12.78,"windBearing":36,"cloudCover":0.06,"uvIndex":3,"visibility":10,"ozone":288.25},{"time":1517695200,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":68.26,"apparentTemperature":68.26,"dewPoint":48.24,"humidity":0.49,"pressure":1020.36,"windSpeed":6.39,"windGust":12.62,"windBearing":37,"cloudCover":0.12,"uvIndex":2,"visibility":10,"ozone":289.4},{"time":1517698800,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":70.26,"apparentTemperature":70.26,"dewPoint":48.65,"humidity":0.46,"pressure":1019.65,"windSpeed":6.07,"windGust":11.84,"windBearing":38,"cloudCover":0.19,"uvIndex":1,"visibility":10,"ozone":290.92},{"time":1517702400,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":70.97,"apparentTemperature":70.97,"dewPoint":48.96,"humidity":0.46,"pressure":1019.18,"windSpeed":5.57,"windGust":10.54,"windBearing":37,"cloudCover":0.23,"uvIndex":1,"visibility":10,"ozone":291.97},{"time":1517706000,"summary":"Clear","icon":"clear-day","precipIntensity":0,"precipProbability":0,"temperature":69.7,"apparentTemperature":69.7,"dewPoint":49.09,"humidity":0.48,"pressure":1019.1,"windSpeed":4.64,"windGust":8.27,"windBearing":28,"cloudCover":0.2,"uvIndex":0,"visibility":10,"ozone":292.03},{"time":1517709600,"summary":"Clear","icon":"clear-night","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":66.98,"apparentTemperature":66.98,"dewPoint":49.13,"humidity":0.53,"pressure":1019.26,"windSpeed":3.4,"windGust":5.45,"windBearing":13,"cloudCover":0.14,"uvIndex":0,"visibility":10,"ozone":291.76},{"time":1517713200,"summary":"Clear","icon":"clear-night","precipIntensity":0.0003,"precipProbability":0.02,"precipType":"rain","temperature":64.64,"apparentTemperature":64.64,"dewPoint":49.17,"humidity":0.57,"pressure":1019.41,"windSpeed":2.65,"windGust":3.6,"windBearing":2,"cloudCover":0.1,"uvIndex":0,"visibility":10,"ozone":291.57},{"time":1517716800,"summary":"Clear","icon":"clear-night","precipIntensity":0.0003,"precipProbability":0.02,"precipType":"rain","temperature":63.2,"apparentTemperature":63.2,"dewPoint":49.21,"humidity":0.6,"pressure":1019.55,"windSpeed":2.48,"windGust":3.28,"windBearing":8,"cloudCover":0.11,"uvIndex":0,"visibility":10,"ozone":291.91},{"time":1517720400,"summary":"Clear","icon":"clear-night","precipIntensity":0.0003,"precipProbability":0.02,"precipType":"rain","temperature":62.27,"apparentTemperature":62.27,"dewPoint":49.25,"humidity":0.62,"pressure":1019.7,"windSpeed":2.78,"windGust":3.63,"windBearing":351,"cloudCover":0.14,"uvIndex":0,"visibility":10,"ozone":292.45},{"time":1517724000,"summary":"Clear","icon":"clear-night","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":61.36,"apparentTemperature":61.36,"dewPoint":49.25,"humidity":0.64,"pressure":1019.81,"windSpeed":2.96,"windGust":3.85,"windBearing":345,"cloudCover":0.18,"uvIndex":0,"visibility":10,"ozone":292.78},{"time":1517727600,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":60.25,"apparentTemperature":60.25,"dewPoint":49.28,"humidity":0.67,"pressure":1019.85,"windSpeed":2.87,"windGust":3.54,"windBearing":354,"cloudCover":0.3,"uvIndex":0,"visibility":10,"ozone":292.64},{"time":1517731200,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0,"precipProbability":0,"temperature":59.21,"apparentTemperature":59.21,"dewPoint":49.31,"humidity":0.7,"pressure":1019.86,"windSpeed":2.84,"windGust":3.11,"windBearing":29,"cloudCover":0.44,"uvIndex":0,"visibility":10,"ozone":292.37},{"time":1517734800,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0,"precipProbability":0,"temperature":58.39,"apparentTemperature":58.39,"dewPoint":49.25,"humidity":0.72,"pressure":1019.74,"windSpeed":2.77,"windGust":2.94,"windBearing":42,"cloudCover":0.55,"uvIndex":0,"visibility":10,"ozone":292.22},{"time":1517738400,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0,"precipProbability":0,"temperature":58.04,"apparentTemperature":58.04,"dewPoint":49.11,"humidity":0.72,"pressure":1019.39,"windSpeed":3.05,"windGust":3.2,"windBearing":48,"cloudCover":0.57,"uvIndex":0,"visibility":10,"ozone":292.34},{"time":1517742000,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0,"precipProbability":0,"temperature":57.86,"apparentTemperature":57.86,"dewPoint":48.89,"humidity":0.72,"pressure":1018.93,"windSpeed":3.44,"windGust":3.71,"windBearing":52,"cloudCover":0.54,"uvIndex":0,"visibility":10,"ozone":292.67},{"time":1517745600,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0,"precipProbability":0,"temperature":57.75,"apparentTemperature":57.75,"dewPoint":48.64,"humidity":0.72,"pressure":1018.69,"windSpeed":3.87,"windGust":4.58,"windBearing":54,"cloudCover":0.53,"uvIndex":0,"visibility":10,"ozone":293.27},{"time":1517749200,"summary":"Partly Cloudy","icon":"partly-cloudy-night","precipIntensity":0,"precipProbability":0,"temperature":57.33,"apparentTemperature":57.33,"dewPoint":48.28,"humidity":0.72,"pressure":1018.81,"windSpeed":4.33,"windGust":6.45,"windBearing":55,"cloudCover":0.57,"uvIndex":0,"visibility":10,"ozone":294.45},{"time":1517752800,"summary":"Mostly Cloudy","icon":"partly-cloudy-night","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":56.96,"apparentTemperature":56.96,"dewPoint":47.9,"humidity":0.72,"pressure":1019.15,"windSpeed":4.85,"windGust":8.82,"windBearing":56,"cloudCover":0.63,"uvIndex":0,"visibility":10,"ozone":295.91},{"time":1517756400,"summary":"Mostly Cloudy","icon":"partly-cloudy-night","precipIntensity":0.0002,"precipProbability":0.02,"precipType":"rain","temperature":57.23,"apparentTemperature":57.23,"dewPoint":47.75,"humidity":0.71,"pressure":1019.52,"windSpeed":5.26,"windGust":10.68,"windBearing":55,"cloudCover":0.66,"uvIndex":0,"visibility":10,"ozone":297.22},{"time":1517760000,"summary":"Mostly Cloudy","icon":"partly-cloudy-day","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":58.54,"apparentTemperature":58.54,"dewPoint":48.03,"humidity":0.68,"pressure":1019.94,"windSpeed":5.48,"windGust":11.75,"windBearing":53,"cloudCover":0.63,"uvIndex":0,"visibility":10,"ozone":298.31},{"time":1517763600,"summary":"Partly Cloudy","icon":"partly-cloudy-day","precipIntensity":0.0001,"precipProbability":0.02,"precipType":"rain","temperature":60.06,"apparentTemperature":60.06,"dewPoint":48.56,"humidity":0.66,"pressure":1020.36,"windSpeed":5.59,"windGust":12.32,"windBearing":50,"cloudCover":0.56,"uvIndex":1,"visibility":10,"ozone":299.26}]},"daily":{"summary":"No precipitation throughout the week, with temperatures bottoming out at 66°F on Monday.","icon":"clear-day","data":[{"time":1517558400,"summary":"Clear throughout the day.","icon":"clear-day","sunriseTime":1517584450,"sunsetTime":1517621713,"moonPhase":0.59,"precipIntensity":0.0001,"precipIntensityMax":0.0018,"precipIntensityMaxTime":1517565600,"precipProbability":0.18,"precipType":"rain","temperatureHigh":69.37,"temperatureHighTime":1517616000,"temperatureLow":56.08,"temperatureLowTime":1517666400,"apparentTemperatureHigh":69.37,"apparentTemperatureHighTime":1517616000,"apparentTemperatureLow":56.08,"apparentTemperatureLowTime":1517666400,"dewPoint":47.99,"humidity":0.67,"pressure":1020.7,"windSpeed":2.73,"windGust":13.14,"windGustTime":1517601600,"windBearing":17,"cloudCover":0.15,"uvIndex":3,"uvIndexTime":1517601600,"visibility":10,"ozone":300.31,"temperatureMin":50.69,"temperatureMinTime":1517583600,"temperatureMax":69.37,"temperatureMaxTime":1517616000,"apparentTemperatureMin":50.69,"apparentTemperatureMinTime":1517583600,"apparentTemperatureMax":69.37,"apparentTemperatureMaxTime":1517616000},{"time":1517644800,"summary":"Partly cloudy overnight.","icon":"partly-cloudy-night","sunriseTime":1517670797,"sunsetTime":1517708181,"moonPhase":0.62,"precipIntensity":0.0001,"precipIntensityMax":0.0003,"precipIntensityMaxTime":1517713200,"precipProbability":0.16,"precipType":"rain","temperatureHigh":70.97,"temperatureHighTime":1517702400,"temperatureLow":56.96,"temperatureLowTime":1517752800,"apparentTemperatureHigh":70.97,"apparentTemperatureHighTime":1517702400,"apparentTemperatureLow":56.96,"apparentTemperatureLowTime":1517752800,"dewPoint":47.28,"humidity":0.59,"pressure":1020.41,"windSpeed":4.14,"windGust":12.78,"windGustTime":1517691600,"windBearing":37,"cloudCover":0.08,"uvIndex":3,"uvIndexTime":1517684400,"visibility":10,"ozone":292.13,"temperatureMin":56.08,"temperatureMinTime":1517666400,"temperatureMax":70.97,"temperatureMaxTime":1517702400,"apparentTemperatureMin":56.08,"apparentTemperatureMinTime":1517666400,"apparentTemperatureMax":70.97,"apparentTemperatureMaxTime":1517702400},{"time":1517731200,"summary":"Partly cloudy in the morning.","icon":"partly-cloudy-day","sunriseTime":1517757142,"sunsetTime":1517794648,"moonPhase":0.66,"precipIntensity":0.0001,"precipIntensityMax":0.0002,"precipIntensityMaxTime":1517814000,"precipProbability":0.1,"precipType":"rain","temperatureHigh":69.12,"temperatureHighTime":1517788800,"temperatureLow":53.49,"temperatureLowTime":1517842800,"apparentTemperatureHigh":69.12,"apparentTemperatureHighTime":1517788800,"apparentTemperatureLow":53.49,"apparentTemperatureLowTime":1517842800,"dewPoint":49.8,"humidity":0.67,"pressure":1019.16,"windSpeed":2.94,"windGust":12.33,"windGustTime":1517767200,"windBearing":21,"cloudCover":0.34,"uvIndex":3,"uvIndexTime":1517774400,"visibility":10,"ozone":295.28,"temperatureMin":56.96,"temperatureMinTime":1517752800,"temperatureMax":69.12,"temperatureMaxTime":1517788800,"apparentTemperatureMin":56.96,"apparentTemperatureMinTime":1517752800,"apparentTemperatureMax":69.12,"apparentTemperatureMaxTime":1517788800},{"time":1517817600,"summary":"Partly cloudy until afternoon.","icon":"partly-cloudy-day","sunriseTime":1517843486,"sunsetTime":1517881116,"moonPhase":0.69,"precipIntensity":0.0003,"precipIntensityMax":0.0009,"precipIntensityMaxTime":1517842800,"precipProbability":0.16,"precipType":"rain","temperatureHigh":66.48,"temperatureHighTime":1517878800,"temperatureLow":53.72,"temperatureLowTime":1517925600,"apparentTemperatureHigh":66.48,"apparentTemperatureHighTime":1517878800,"apparentTemperatureLow":53.72,"apparentTemperatureLowTime":1517925600,"dewPoint":50.57,"humidity":0.75,"pressure":1017.57,"windSpeed":1.67,"windGust":6.77,"windGustTime":1517875200,"windBearing":318,"cloudCover":0.35,"uvIndex":2,"uvIndexTime":1517857200,"visibility":10,"ozone":298.75,"temperatureMin":53.49,"temperatureMinTime":1517842800,"temperatureMax":66.48,"temperatureMaxTime":1517878800,"apparentTemperatureMin":53.49,"apparentTemperatureMinTime":1517842800,"apparentTemperatureMax":66.48,"apparentTemperatureMaxTime":1517878800},{"time":1517904000,"summary":"Clear throughout the day.","icon":"clear-day","sunriseTime":1517929829,"sunsetTime":1517967584,"moonPhase":0.72,"precipIntensity":0,"precipIntensityMax":0.0002,"precipIntensityMaxTime":1517936400,"precipProbability":0,"temperatureHigh":69.43,"temperatureHighTime":1517961600,"temperatureLow":56.7,"temperatureLowTime":1518015600,"apparentTemperatureHigh":69.43,"apparentTemperatureHighTime":1517961600,"apparentTemperatureLow":56.7,"apparentTemperatureLowTime":1518015600,"dewPoint":46.38,"humidity":0.6,"pressure":1018.5,"windSpeed":3.5,"windGust":12.02,"windGustTime":1517947200,"windBearing":16,"cloudCover":0.01,"uvIndex":3,"uvIndexTime":1517943600,"ozone":314.21,"temperatureMin":53.72,"temperatureMinTime":1517925600,"temperatureMax":69.43,"temperatureMaxTime":1517961600,"apparentTemperatureMin":53.72,"apparentTemperatureMinTime":1517925600,"apparentTemperatureMax":69.43,"apparentTemperatureMaxTime":1517961600},{"time":1517990400,"summary":"Partly cloudy in the afternoon.","icon":"partly-cloudy-day","sunriseTime":1518016170,"sunsetTime":1518054051,"moonPhase":0.75,"precipIntensity":0,"precipIntensityMax":0.0001,"precipIntensityMaxTime":1518055200,"precipProbability":0,"temperatureHigh":70.19,"temperatureHighTime":1518048000,"temperatureLow":54.9,"temperatureLowTime":1518098400,"apparentTemperatureHigh":70.19,"apparentTemperatureHighTime":1518048000,"apparentTemperatureLow":54.9,"apparentTemperatureLowTime":1518098400,"dewPoint":46.56,"humidity":0.58,"pressure":1021.77,"windSpeed":5.68,"windGust":13.75,"windGustTime":1518026400,"windBearing":43,"cloudCover":0.08,"uvIndex":3,"uvIndexTime":1518030000,"ozone":297.8,"temperatureMin":56.7,"temperatureMinTime":1518015600,"temperatureMax":70.19,"temperatureMaxTime":1518048000,"apparentTemperatureMin":56.7,"apparentTemperatureMinTime":1518015600,"apparentTemperatureMax":70.19,"apparentTemperatureMaxTime":1518048000},{"time":1518076800,"summary":"Partly cloudy overnight.","icon":"partly-cloudy-night","sunriseTime":1518102509,"sunsetTime":1518140518,"moonPhase":0.78,"precipIntensity":0,"precipIntensityMax":0.0001,"precipIntensityMaxTime":1518102000,"precipProbability":0,"temperatureHigh":71.29,"temperatureHighTime":1518134400,"temperatureLow":56.81,"temperatureLowTime":1518184800,"apparentTemperatureHigh":71.29,"apparentTemperatureHighTime":1518134400,"apparentTemperatureLow":56.81,"apparentTemperatureLowTime":1518184800,"dewPoint":46.21,"humidity":0.57,"pressure":1019.29,"windSpeed":3.67,"windGust":7.05,"windGustTime":1518112800,"windBearing":4,"cloudCover":0.01,"uvIndex":4,"uvIndexTime":1518120000,"ozone":289.54,"temperatureMin":54.9,"temperatureMinTime":1518098400,"temperatureMax":71.29,"temperatureMaxTime":1518134400,"apparentTemperatureMin":54.9,"apparentTemperatureMinTime":1518098400,"apparentTemperatureMax":71.29,"apparentTemperatureMaxTime":1518134400},{"time":1518163200,"summary":"Partly cloudy until afternoon.","icon":"partly-cloudy-day","sunriseTime":1518188847,"sunsetTime":1518226986,"moonPhase":0.82,"precipIntensity":0.0001,"precipIntensityMax":0.0002,"precipIntensityMaxTime":1518166800,"precipProbability":0.18,"precipType":"rain","temperatureHigh":67.97,"temperatureHighTime":1518217200,"temperatureLow":57.17,"temperatureLowTime":1518256800,"apparentTemperatureHigh":67.97,"apparentTemperatureHighTime":1518217200,"apparentTemperatureLow":57.17,"apparentTemperatureLowTime":1518256800,"dewPoint":41.26,"humidity":0.49,"pressure":1015.65,"windSpeed":8.61,"windGust":38.61,"windGustTime":1518246000,"windBearing":358,"cloudCover":0.26,"uvIndex":3,"uvIndexTime":1518206400,"ozone":313.84,"temperatureMin":56.81,"temperatureMinTime":1518184800,"temperatureMax":67.97,"temperatureMaxTime":1518217200,"apparentTemperatureMin":56.81,"apparentTemperatureMinTime":1518184800,"apparentTemperatureMax":67.97,"apparentTemperatureMaxTime":1518217200}]},"flags":{"sources":["isd","nearest-precip","nwspa","cmc","gfs","hrrr","madis","nam","sref","darksky"],"isd-stations":["724943-99999","745039-99999","745045-99999","745060-23239","745065-99999","994016-99999","994033-99999","994036-99999","997734-99999","998197-99999","998476-99999","998477-99999","998479-99999","998496-99999","999999-23239","999999-23272"],"units":"us"},"offset":-8}
"""
