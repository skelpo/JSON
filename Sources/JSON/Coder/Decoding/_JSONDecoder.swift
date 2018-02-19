import Foundation

internal final class _JSONDecoder: Decoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    let json: JSON
    
    init(codingPath: [CodingKey], json: JSON) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.json = json
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard self.json.isObject else {
            throw DecodingError.expectedType([String: JSON].self, at: self.codingPath, from: self.json)
        }
        
        let container = _JSONKeyedValueDecoder<Key>.init(at: self.codingPath, wrapping: json)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard self.json.isArray else {
            throw DecodingError.expectedType([JSON].self, at: self.codingPath, from: self.json)
        }
        
        return _JSONUnkeyedDecoder(at: self.codingPath, wrapping: json)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return _JSONSingleValueDecoder(at: self.codingPath, wrapping: self.json)
    }
    
    static func decode<T>(_ type: T.Type, from json: JSON)throws -> T where T: Decodable {
        let decoder = self.init(codingPath: [], json: json)
        return try T.init(from: decoder)
    }
}
