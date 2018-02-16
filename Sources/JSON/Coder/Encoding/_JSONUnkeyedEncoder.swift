import Foundation

internal final class _JSONUnkeyedEncoder: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    var json: JSONContainer
    
    init(at codingPath: [CodingKey], wrapping json: JSONContainer) {
        self.codingPath = codingPath
        
        precondition(json.isArray, "JSON structure must be an array")
        self.json = json
    }
    
    var count: Int {
        return json.count!
    }
    
    public func encodeNil()             throws { try self.json.append(.null) }
    public func encode(_ value: Bool)   throws { try self.json.append(value) }
    public func encode(_ value: Int)    throws { try self.json.append(value) }
    public func encode(_ value: String) throws { try self.json.append(value) }
    public func encode(_ value: Float)  throws { try self.json.append(value) }
    public func encode(_ value: Double) throws { try self.json.append(value) }
    
    public func encode<T : Encodable>(_ value: T) throws {
        let encoder = _JSONEncoder(codingPath: self.codingPath + [JSON.CodingKeys(intValue: self.count)], json: JSONContainer(json: [:]))
        try value.encode(to: encoder)
        try self.json.append(encoder.container.json)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let dictionary = JSONContainer(json: [:])
        try! self.json.append(dictionary.json)
        
        let container = _JSONKeyedEncoder<NestedKey>(at: self.codingPath + [JSON.CodingKeys(intValue: self.count)], wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let array = JSONContainer(json: [])
        try! self.json.append(array.json)
        
        return _JSONUnkeyedEncoder(at: self.codingPath + [JSON.CodingKeys(intValue: self.count)], wrapping: array)
    }
    
    func superEncoder() -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath, json: self.json)
    }
}
