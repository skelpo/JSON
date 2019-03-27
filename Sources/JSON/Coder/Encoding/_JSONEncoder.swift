import Foundation

internal final class _JSONEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var container: JSONContainer!
    
    init(codingPath: [CodingKey] = [], json: JSONContainer? = nil) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.container = json
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if self.container == nil { self.container = JSONContainer(json: [:]) }
        precondition(self.container.json.isObject, "JSON must have an object structure")
        
        let container = _JSONKeyedEncoder<Key>(at: self.codingPath, wrapping: self.container)
        return .init(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if self.container == nil { self.container = JSONContainer(json: []) }
        precondition(self.container.json.isArray, "JSON must have an array structure")
        
        return _JSONUnkeyedEncoder(at: self.codingPath, wrapping: self.container)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        if self.container == nil { self.container = JSONContainer(json: .null) }
        return _JSONSingleValueEncoder(at: self.codingPath, wrapping: self.container)
    }
    
    static func encode<T>(_ t: T)throws -> JSON where T: Encodable {
        let encoder = _JSONEncoder()
        try t.encode(to: encoder)
        return encoder.container.json
    }
}

internal final class JSONContainer {
    var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
}
