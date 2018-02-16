import Foundation

internal final class _JSONKeyedEncoder<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    var codingPath: [CodingKey]
    var json: JSONContainer
    
    init(at codingPath: [CodingKey], wrapping json: JSONContainer) {
        self.codingPath = codingPath
        
        precondition(json.isObject, "JSON must have an object structure")
        self.json = json
    }
    
    func encodeNil(forKey key: Key) throws {
        try self.json.set(key.stringValue, .null)
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        try self.json.set(key.stringValue, to: value)
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        try self.json.set(key.stringValue, to: value)
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        try self.json.set(key.stringValue, to: value)
    }
    
    func encode(_ value: Float, forKey key: Key) throws {
        try self.json.set(key.stringValue, to: value)
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        try self.json.set(key.stringValue, to: value)
    }
    
    func encode<T : Encodable>(_ value: T, forKey key: Key) throws {        
        let encoder = _JSONEncoder(codingPath: self.codingPath + [key], json: JSONContainer(json: [:]))
        try value.encode(to: encoder)
        try self.json.set(key.stringValue, encoder.container.json)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let jsonContainer = JSONContainer(json: [:])
        try! self.json.set(key.stringValue, jsonContainer.json)
        
        let container = _JSONKeyedEncoder<NestedKey>(at: self.codingPath + [key], wrapping: jsonContainer)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let jsonContainer = JSONContainer(json: [])
        try! self.json.set(key.stringValue, jsonContainer.json)
        
        return _JSONUnkeyedEncoder(at: self.codingPath + [key], wrapping: jsonContainer)
    }
    
    func superEncoder() -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath, json: self.json)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath + [key], json: self.json)
    }
}

