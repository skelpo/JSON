import Foundation

internal final class _JSONEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var json: JSON!
    
    init(codingPath: [CodingKey] = [], json: JSON? = nil) {
        self.codingPath = codingPath
        self.json = json
        self.userInfo = [:]
    }
    
    var canEncodeNewValue: Bool {
        return (self.json.count == nil ? 1 : self.json.count!) == self.codingPath.count
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if self.json == nil { self.json = [:] }
        precondition(self.json.isObject, "JSON must have an object structure")
        
        let container = _JSONKeyedEncoder<Key>(at: self.codingPath, wrapping: self.json)
        return .init(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if self.json == nil { self.json = [] }
        precondition(self.json.isArray, "JSON must have an array structure")
        
        return _JSONUnkeyedEncoder(at: self.codingPath, wrapping: self.json)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
    
    static func encode<T>(_ t: T)throws -> JSON where T: Encodable {
        let encoder = _JSONEncoder()
        try t.encode(to: encoder)
        return encoder.json
    }
}
