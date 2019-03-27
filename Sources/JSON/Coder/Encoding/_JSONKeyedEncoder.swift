import Foundation

internal final class _JSONKeyedEncoder<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    var codingPath: [CodingKey]
    var container: JSONContainer
    
    init(at codingPath: [CodingKey], wrapping container: JSONContainer) {
        self.codingPath = codingPath
        
        precondition(container.json.isObject, "JSON must have an object structure")
        self.container = container
    }
    
    func encodeNil(forKey key: Key)               throws { self.container.json[key.stringValue] = .null }
    func encode(_ value: Bool, forKey key: Key)   throws { self.container.json[key.stringValue] = value.json }
    func encode(_ value: Int, forKey key: Key)    throws { self.container.json[key.stringValue] = value.json }
    func encode(_ value: String, forKey key: Key) throws { self.container.json[key.stringValue] = value.json }
    func encode(_ value: Float, forKey key: Key)  throws { self.container.json[key.stringValue] = value.json }
    func encode(_ value: Double, forKey key: Key) throws { self.container.json[key.stringValue] = value.json }
    
    func encode<T : Encodable>(_ value: T, forKey key: Key) throws {        
        let encoder = _JSONEncoder(codingPath: self.codingPath + [key])
        try value.encode(to: encoder)
        self.container.json[key.stringValue] = encoder.container.json
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _JSONKeyedEncoder<NestedKey>(at: self.codingPath + [key], wrapping: self.container)
        return .init(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return _JSONUnkeyedEncoder(at: self.codingPath + [key], wrapping: self.container)
    }
    
    func superEncoder() -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath, json: self.container)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath + [key], json: self.container)
    }
}

