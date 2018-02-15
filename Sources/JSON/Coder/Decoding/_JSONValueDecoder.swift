import Foundation

internal struct _JSONValueDecoder<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K
    
    var json: [String: JSON]
    var codingPath: [CodingKey]
    var decoder: _JSONDecoder
    
    init(referance: _JSONDecoder, wrapping json: JSON) {
        self.decoder = referance
        self.codingPath = decoder.codingPath
        
        precondition(json.isObject, "JSON must have an object structure")
        guard case let JSON.object(structure) = json else {
            fatalError()
        }
        self.json = structure
    }
    
    var allKeys: [Key] {
        return json.keys.compactMap ({ return Key(stringValue: $0) })
    }
    
    func contains(_ key: Key) -> Bool {
        return self.json[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        guard let entry = self.json[key.stringValue] else {
            throw DecodingError.badKey(key, at: self.decoder.codingPath)
        }
        
        guard case JSON.null = entry else {
            return false
        }
        return true
    }
    
    func _decode<T>(_ type: T.Type, forKey key: Key)throws -> T where T: Decodable {
        guard let json = self.json[key.stringValue] else {
            throw DecodingError.badKey(key, at: self.decoder.codingPath)
        }
        
        return try json.value(for: type, at: self.decoder.codingPath)
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try _decode(type, forKey: key)
    }
    
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return try _decode(type, forKey: key)
    }
    
    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return try _decode(type, forKey: key)
    }
    
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return try _decode(type, forKey: key)
    }
    
    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        return try _decode(type, forKey: key)
    }
    
    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        let value = self.json[key.stringValue] ?? JSON.null
        return _JSONDecoder(codingPath: self.decoder.codingPath, json: value)
    }
    
    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: Key(stringValue: "super")!)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = self.json[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \(key)")
            )
        }
        
        guard value.isObject else {
            throw DecodingError.expectedType([String: JSON].self, at: self.decoder.codingPath, from: value)
        }
        
        let container = _JSONValueDecoder<NestedKey>.init(referance: self.decoder, wrapping: value)
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = self.json[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(key)")
            )
        }
        
        guard value.isArray else {
            throw DecodingError.typeMismatch(
                [JSON].self,
                DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Cannot create UnkeyedContainer from non-array data structure")
            )
        }
        
        return _JSONUnkeyedDecoder(referance: self.decoder, wrapping: value)
    }
}

extension DecodingError {
    static func badKey(_ key: CodingKey, at path: [CodingKey]) -> DecodingError {
        return DecodingError.keyNotFound(
            key,
            DecodingError.Context(
                codingPath: path,
                debugDescription: "No value associated with key \(key).")
        )
    }
}
