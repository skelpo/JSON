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
    
    func decode(_ type: Bool.Type) throws -> Bool {
        return try self.json.value(for: type, at: self.codingPath)
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        return try self.json.value(for: type, at: self.codingPath)
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        return try self.json.value(for: type, at: self.codingPath)
    }
    
    func decode(_ type: String.Type) throws -> String {
        return try self.json.value(for: type, at: self.codingPath)
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let decoder = _JSONDecoder(codingPath: self.codingPath, json: self.json)
        return try T.init(from: decoder)
        // return try self.json.value(for: type, at: self.codingPath)
    }
}
