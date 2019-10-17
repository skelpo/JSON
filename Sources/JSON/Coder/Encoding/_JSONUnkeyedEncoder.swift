import Foundation

internal final class _JSONUnkeyedEncoder: UnkeyedEncodingContainer {
    var encoder: _JSONEncoder
    var codingPath: [CodingKey]

    var jsonPath: [String]
    var container: JSONContainer { self.encoder.container }

    init(for encoder: _JSONEncoder, path: [CodingKey]? = nil) {
        self.encoder = encoder
        self.codingPath = path ?? encoder.codingPath

        self.jsonPath = self.codingPath.map { $0.stringValue }
    }
    
    var count: Int {
        return encoder.container.json.array?.count ?? 0
    }
    
    func encodeNil()             throws { self.container.assign(path: self.jsonPath, to: .null) }
    func encode(_ value: Bool)   throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: Int)    throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: String) throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: Float)  throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: Double) throws { self.container.assign(path: self.jsonPath, to: value.json) }

    func encode(_ value: Int8)   throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: Int16)  throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: Int32)  throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: Int64)  throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: UInt8)  throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: UInt16) throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: UInt32) throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: UInt64) throws { self.container.assign(path: self.jsonPath, to: value.json) }
    func encode(_ value: Decimal) throws { self.container.assign(path: self.jsonPath, to: value.json) }

    func encode<T : Encodable>(_ value: T) throws {
        try value.encode(to: encoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _JSONKeyedEncoder<NestedKey>(for: self.encoder)
        return .init(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _JSONUnkeyedEncoder(for: self.encoder)
    }
    
    func superEncoder() -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath, json: self.container)
    }
}
