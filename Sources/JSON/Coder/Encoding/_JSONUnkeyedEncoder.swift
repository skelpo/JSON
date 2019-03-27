import Foundation

internal final class _JSONUnkeyedEncoder: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    var container: JSONContainer
    
    init(at codingPath: [CodingKey], wrapping container: JSONContainer) {
        self.codingPath = codingPath
        
        precondition(container.json.isArray, "JSON structure must be an array")
        self.container = container
    }
    
    var count: Int {
        return container.json.array?.count ?? 0
    }
    
    public func encodeNil()             throws { self.container.json.array?.append(.null) }
    public func encode(_ value: Bool)   throws { self.container.json.array?.append(value.json) }
    public func encode(_ value: Int)    throws { self.container.json.array?.append(value.json) }
    public func encode(_ value: String) throws { self.container.json.array?.append(value.json) }
    public func encode(_ value: Float)  throws { self.container.json.array?.append(value.json) }
    public func encode(_ value: Double) throws { self.container.json.array?.append(value.json) }
    
    public func encode<T : Encodable>(_ value: T) throws {
        let encoder = _JSONEncoder(codingPath: self.codingPath + [JSON.CodingKeys(intValue: self.count)])
        try value.encode(to: encoder)
        self.container.json.array?.append(encoder.container.json)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _JSONKeyedEncoder<NestedKey>(at: self.codingPath + [JSON.CodingKeys(intValue: self.count)], wrapping: self.container)
        return .init(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _JSONUnkeyedEncoder(at: self.codingPath + [JSON.CodingKeys(intValue: self.count)], wrapping: self.container)
    }
    
    func superEncoder() -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath, json: self.container)
    }
}
