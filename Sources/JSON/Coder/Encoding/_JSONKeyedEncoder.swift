import Foundation

internal final class _JSONKeyedEncoder<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    let encoder: _JSONEncoder
    var codingPath: [CodingKey]

    var jsonPath: [String]
    var container: JSONContainer { self.encoder.container }

    init(for encoder: _JSONEncoder, path: [CodingKey]? = nil) {
        self.encoder = encoder
        self.codingPath = path ?? encoder.codingPath

        self.jsonPath = self.codingPath.map { $0.stringValue }
    }
    
    func encodeNil(forKey key: Key)               throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: .null) }
    func encode(_ value: Bool, forKey key: Key)   throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: Int, forKey key: Key)    throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: String, forKey key: Key) throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: Float, forKey key: Key)  throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: Double, forKey key: Key) throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }

    func encode(_ value: Int8, forKey key: Key)   throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: Int16, forKey key: Key)  throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: Int32, forKey key: Key)  throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: Int64, forKey key: Key)  throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: UInt8, forKey key: Key)   throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: UInt16, forKey key: Key)  throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: UInt32, forKey key: Key)  throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }
    func encode(_ value: UInt64, forKey key: Key)  throws { self.container.assign(path: self.jsonPath, key: key.stringValue, to: value.json) }

    func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        if let json = try? (value as? FailableJSONRepresentable)?.failableJSON() {
            self.container.assign(path: self.jsonPath, key: key.stringValue, to: json)
        } else {
            self.encoder.codingPath.append(key)
            defer { self.encoder.codingPath.removeLast() }

            try self.container.assign(path: self.jsonPath, key: key.stringValue, to: _JSONEncoder.encode(value))
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _JSONKeyedEncoder<NestedKey>(for: self.encoder, path: self.codingPath + [key])
        return .init(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return _JSONUnkeyedEncoder(for: self.encoder, path: self.codingPath + [key])
    }
    
    func superEncoder() -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath, json: self.container)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return _JSONEncoder(codingPath: self.codingPath + [key], json: self.container)
    }
}
