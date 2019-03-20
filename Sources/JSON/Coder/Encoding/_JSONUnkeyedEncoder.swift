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
        return json.json.array?.count ?? 0
    }
    
    public func encodeNil()             throws { self.json.append(.null) }
    public func encode(_ value: Bool)   throws { try self.json.append(value) }
    public func encode(_ value: Int)    throws { try self.json.append(value) }
    public func encode(_ value: String) throws { try self.json.append(value) }
    public func encode(_ value: Float)  throws { try self.json.append(value) }
    public func encode(_ value: Double) throws { try self.json.append(value) }
    
    public func encode<T : Encodable>(_ value: T) throws {
        let encoder = _JSONEncoder(codingPath: self.codingPath + [JSON.CodingKeys(intValue: self.count)])
        try value.encode(to: encoder)
        self.json.append(encoder.container.json)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _JSONKeyedEncoder<NestedKey>(at: self.codingPath + [JSON.CodingKeys(intValue: self.count)], wrapping: self.json)
        return .init(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _JSONUnkeyedEncoder(at: self.codingPath + [JSON.CodingKeys(intValue: self.count)], wrapping: self.json)
    }
    
    func superEncoder() -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath, json: self.json)
    }
}
