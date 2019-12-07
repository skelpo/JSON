import Foundation

internal struct _JSONUnkeyedDecoder: UnkeyedDecodingContainer {
    var count: Int?
    var currentIndex: Int
    var codingPath: [CodingKey]
    let json: [JSON]
    
    init(at path: [CodingKey], wrapping json: JSON) {
        self.codingPath = path
        self.currentIndex = 0
        
        precondition(json.isArray, "JSON must have an array structure")
        guard case let JSON.array(elements) = json else {
            fatalError()
        }
        
        self.json = elements
        self.count = elements.count
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
    
    mutating func decode(_ type: Bool.Type)   throws -> Bool   { return try self.pop(as: type) }
    mutating func decode(_ type: Int.Type)    throws -> Int    { return try self.pop(as: type) }
    mutating func decode(_ type: Float.Type)  throws -> Float  { return try self.pop(as: type) }
    mutating func decode(_ type: Double.Type) throws -> Double { return try self.pop(as: type) }
    mutating func decode(_ type: String.Type) throws -> String { return try self.pop(as: type) }
    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable { return try self.pop(as: type) }

    mutating func decode(_ type: Int8.Type)   throws -> Int8   { return try self.pop(as: type) }
    mutating func decode(_ type: Int16.Type)  throws -> Int16  { return try self.pop(as: type) }
    mutating func decode(_ type: Int32.Type)  throws -> Int32  { return try self.pop(as: type) }
    mutating func decode(_ type: Int64.Type)  throws -> Int64  { return try self.pop(as: type) }
    mutating func decode(_ type: UInt8.Type)  throws -> UInt8  { return try self.pop(as: type) }
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 { return try self.pop(as: type) }
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 { return try self.pop(as: type) }
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 { return try self.pop(as: type) }

    mutating func decode(_ type: Date.Type) throws -> Date {
        let json = self.pop()
        guard case let .number(.double(interval)) = json  else {
            throw DecodingError.expectedType(Double.self, at: self.codingPath, from: json)
        }

        return Date(timeIntervalSince1970: interval)
    }

    // TODO: - https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/JSONEncoder.swift#L1852
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
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
            throw DecodingError.expectedType([String: JSON].self, at: self.codingPath + [JSON.CodingKeys(intValue: self.currentIndex)], from: value)
        }
        
        self.currentIndex += 1
        let container = _JSONKeyedValueDecoder<NestedKey>(at: self.codingPath + [JSON.CodingKeys(intValue: self.currentIndex)], wrapping: value)
        return KeyedDecodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
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
            throw DecodingError.expectedType([JSON].self, at: self.codingPath + [JSON.CodingKeys(intValue: self.currentIndex)], from: value)
        }
        
        self.currentIndex += 1
        return _JSONUnkeyedDecoder(at: self.codingPath + [JSON.CodingKeys(intValue: self.currentIndex)], wrapping: value)
    }
    
    mutating func superDecoder() throws -> Decoder {
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
        
        return _JSONDecoder(codingPath: self.codingPath + [JSON.CodingKeys(intValue: self.currentIndex)], json: value)
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
