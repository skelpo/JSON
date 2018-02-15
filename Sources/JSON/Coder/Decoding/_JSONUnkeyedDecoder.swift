import Foundation

internal struct _JSONUnkeyedDecoder: UnkeyedDecodingContainer {
    var count: Int?
    var currentIndex: Int
    var codingPath: [CodingKey]
    let json: [JSON]
    let decoder: _JSONDecoder
    
    init(referance: _JSONDecoder, wrapping json: JSON) {
        self.codingPath = referance.codingPath
        self.currentIndex = 0
        
        precondition(json.isArray, "JSON must have an array structure")
        guard case let JSON.array(elements) = json else {
            fatalError()
        }
        
        self.json = elements
        self.count = elements.count
        self.decoder = referance
    }
    
    var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }
    
    mutating func pop() -> JSON {
        defer { self.currentIndex += 1 }
        return json[self.currentIndex]
    }
    
    mutating func pop<T>(as: T.Type)throws -> T where T: Decodable {
        guard !self.isAtEnd else {
            throw DecodingError.badIndex(with: T.self, at: self.codingPath, and: self.currentIndex)
        }
        return try self.pop().value(for: T.self, at: self.codingPath)
    }
    
    mutating func decodeNil() throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.badIndex(with: Any?.self, at: self.codingPath, and: self.currentIndex)
        }
        
        guard case JSON.null = self.pop() else {
            return false
        }
        return true
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try self.pop(as: type)
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        return try self.pop(as: type)
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        return try self.pop(as: type)
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        return try self.pop(as: type)
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try self.pop(as: type)
    }
    
    // TODO: - https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/JSONEncoder.swift#L1852
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        self.decoder.codingPath.append(JSON.CodingKeys(intValue: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(
                KeyedDecodingContainer<NestedKey>.self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
                )
            )
        }
        
        let value = self.json[self.currentIndex]
        guard value.isObject else {
            throw DecodingError.expectedType([String: JSON].self, at: self.codingPath, from: value)
        }
        
        self.currentIndex += 1
        let container = _JSONValueDecoder<NestedKey>(referance: self.decoder, wrapping: value)
        return KeyedDecodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(JSON.CodingKeys(intValue: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(
                UnkeyedDecodingContainer.self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get nested unkeyed container -- unkeyed container is at end."
                )
            )
        }
        
        let value = self.json[self.currentIndex]
        guard value.isArray else {
            throw DecodingError.expectedType([JSON].self, at: self.codingPath, from: value)
        }
        
        self.currentIndex += 1
        return _JSONUnkeyedDecoder(referance: self.decoder, wrapping: value)
    }
    
    mutating func superDecoder() throws -> Decoder {
        self.decoder.codingPath.append(JSON.CodingKeys(intValue: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(
                UnkeyedDecodingContainer.self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get nested unkeyed container -- unkeyed container is at end."
                )
            )
        }
        
        let value = self.json[self.currentIndex]
        self.currentIndex += 1
        
        return _JSONDecoder(codingPath: self.decoder.codingPath, json: value)
    }
}

extension DecodingError {
    static func badIndex(with type: Any.Type, at path: [CodingKey], and index: Int) -> DecodingError {
        return DecodingError.valueNotFound(
            type,
            DecodingError.Context(
                codingPath: path + [JSON.CodingKeys(intValue: index)],
                debugDescription: "Unkeyed container is at end.")
        )
    }
}
