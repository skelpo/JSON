extension JSON: Codable {
    
    /// See `Decodable.init(from:)`.
    public init(from decoder: Decoder) throws {
        if var container = try? decoder.container(keyedBy: CodingKeys.self) {
            self = try JSON(from: &container)
        } else if var container = try? decoder.unkeyedContainer() {
            self = try JSON(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self = try JSON(from: container)
        }
    }

    /// See `Encodable.encode(to:)`.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(structure):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try self.encode(object: structure, with: &container)
        case let .array(sequence):
            var container = encoder.unkeyedContainer()
            try self.encode(array: sequence, with: &container)
        default:
            var container = encoder.singleValueContainer()
            try self.encode(value: self, with: &container)
        }
    }
    
    /// A generic `CodingKey` type that supports any value.
    public struct CodingKeys: CodingKey {
        
        /// See `CodingKey.stringValue`.
        public var stringValue: String
        
        /// See `CodingKey.intValue`.
        public var intValue: Int?
        
        /// See `CodingKey.init(stringValue:)`.
        ///
        /// If the string passed in is convertible to an `Int`, the `intValue` property is set.
        public init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = Int(stringValue)
        }
        
        /// See `CodingKey.init(intValue:)`.
        ///
        /// The `.stringValue` property is set to the string representation of the `Int`.
        public init(intValue: Int) {
            self.stringValue = String(describing: intValue)
            self.intValue = intValue
        }
    }
    
    // MARK: - Private Decoder Inits
    
    private init(from container: inout KeyedDecodingContainer<CodingKeys>)throws {
        let object: [String: JSON] = try container.allKeys.reduce(into: [:]) { object, key in
            if let value = try? container.decodeNil(forKey: key), value {
                object[key.stringValue] = .null
            } else if let value = try? container.decode(String.self, forKey: key) {
                object[key.stringValue] = .string(value)
            } else if let value = try? container.decode(Number.self, forKey: key) {
                object[key.stringValue] = .number(value)
            } else if let value = try? container.decode(Bool.self, forKey: key) {
                object[key.stringValue] = .bool(value)
            } else if var con = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: key) {
                object[key.stringValue] = try JSON(from: &con)
            } else if var con = try? container.nestedUnkeyedContainer(forKey: key) {
                object[key.stringValue] = try JSON(from: &con)
            } else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Un-supported type found in JSON")
            }
        }

        self = .object(object)
    }
    
    private init(from container: inout UnkeyedDecodingContainer)throws {
        var array: [JSON] = []
        
        array.reserveCapacity(container.count ?? 0)
        while !container.isAtEnd {
            if let value = try? container.decodeNil(), value {
                array.append(.null)
            } else if let value = try? container.decode(String.self) {
                array.append(.string(value))
            } else if let value = try? container.decode(Number.self) {
                array.append(.number(value))
            } else if let value = try? container.decode(Bool.self) {
                array.append(.bool(value))
            } else if var con = try? container.nestedContainer(keyedBy: CodingKeys.self) {
                try array.append(JSON(from: &con))
            } else if var con = try? container.nestedUnkeyedContainer() {
                try array.append(JSON(from: &con))
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Un-supported type found in JSON")
            }
        }
        
        self = .array(array)
    }
    
    private init(from container: SingleValueDecodingContainer)throws {
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Number.self) {
            self = .number(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Un-supported type found in JSON")
        }
    }
    
    // MARK: - Private Encoder Methods
    
    private func encode(object: [String: JSON], with container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try object.forEach { key, value in
            let key = CodingKeys(stringValue: key)
            
            switch value {
            case .null: try container.encodeNil(forKey: key)
            case let .string(value): try container.encode(value, forKey: key)
            case let .number(value): try container.encode(value, forKey: key)
            case let .bool(value): try container.encode(value, forKey: key)
            case let .object(value):
                var con = container.nestedContainer(keyedBy: CodingKeys.self, forKey: key)
                try encode(object: value, with: &con)
            case let .array(value):
                var con = container.nestedUnkeyedContainer(forKey: key)
                try encode(array: value, with: &con)
            }
        }
    }
    
    private func encode(array: [JSON], with container: inout UnkeyedEncodingContainer) throws {
        try array.forEach { element in
            switch element {
            case .null: try container.encodeNil()
            case let .string(value): try container.encode(value)
            case let .number(value): try container.encode(value)
            case let .bool(value): try container.encode(value)
            case let .object(value):
                var con = container.nestedContainer(keyedBy: CodingKeys.self)
                try encode(object: value, with: &con)
            case let .array(value):
                var con = container.nestedUnkeyedContainer()
                try encode(array: value, with: &con)
            }
        }
    }
    
    private func encode(value: JSON, with container: inout SingleValueEncodingContainer)throws {
        switch value {
        case .null: try container.encodeNil()
        case let .string(value): try container.encode(value)
        case let .bool(value): try container.encode(value)
        case let .number(value): try container.encode(value)
        case .object:
            throw EncodingError.invalidValue(
                [String: JSON].self,
                .init(codingPath: container.codingPath, debugDescription: "Cannot encode object to single value encoder")
            )
        case .array:
            throw EncodingError.invalidValue(
                [JSON].self,
                .init(codingPath: container.codingPath, debugDescription: "Cannot encode array to single value encoder")
            )
        }
    }
}
