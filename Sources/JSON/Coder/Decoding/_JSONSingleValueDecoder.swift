import Foundation

internal struct _JSONSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    let json: JSON
    
    init(at path: [CodingKey], wrapping json: JSON) {
        self.codingPath = path
        self.json = json
    }
    
    func decodeNil() -> Bool {
        guard case JSON.null = json else {
            return false
        }
        return true
    }
    
    func decode(_ type: Bool.Type)   throws -> Bool { return try self.json.value(for: type, at: self.codingPath) }
    func decode(_ type: Int.Type)    throws -> Int { return try self.json.value(for: type, at: self.codingPath) }
    func decode(_ type: Float.Type)  throws -> Float { return try self.json.value(for: type, at: self.codingPath) }
    func decode(_ type: Double.Type) throws -> Double { return try self.json.value(for: type, at: self.codingPath) }
    func decode(_ type: String.Type) throws -> String { return try self.json.value(for: type, at: self.codingPath) }

    func decode(_ type: Int8.Type) throws -> Int8 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: Int16.Type) throws -> Int16 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: Int32.Type) throws -> Int32 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: Int64.Type) throws -> Int64 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: UInt8.Type) throws -> UInt8 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { return try self.json.number(at: self.codingPath, as: type) }
    func decode(_ type: Decimal.Type) throws -> Decimal { return try self.json.value(for: type, at: self.codingPath) }


    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let decoder = _JSONDecoder(codingPath: self.codingPath, json: self.json)
        return try T.init(from: decoder)
    }
}
