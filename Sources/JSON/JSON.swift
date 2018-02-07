public enum JSON: Codable {
    
    // MARK: - Cases
    case null
    case string(String)
    case number(Number)
    case bool(Bool)
    indirect case array([JSON])
    indirect case object([String: JSON])
    
    // MARK: - Public Methods
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JSON.CodingKeys.self) {
            self = try JSON(from: container)
        } else if let container = try? decoder.unkeyedContainer() {
            self = try JSON(from: container)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [], debugDescription: "No top-level object or array found"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(structure):
            let container = encoder.container(keyedBy: JSON.CodingKeys.self)
            try self.encode(object: structure, with: container)
        case let .array(sequence):
            let container = encoder.unkeyedContainer()
            try self.encode(array: sequence, with: container)
        default:
            throw EncodingError.invalidValue(self, EncodingError.Context.init(codingPath: [], debugDescription: "Top-level value must be array or object"))
        }
    }
    
    public mutating func append(_ json: JSON)throws {
        switch self {
        case var .array(sequence):
            sequence.append(json)
            self = .array(sequence)
        default: throw JSONError.unableToMergeCases(self, json)
        }
    }
    
    public mutating func set(_ key: String, _ json: JSON)throws {
        switch self {
        case var .object(structure):
            structure[key] = json
            self = .object(structure)
        default: throw JSONError.unableToMergeCases(self, json)
        }
    }
    
    public func merge(_ json: JSON)throws -> JSON {
        guard case let JSON.object(new) = json, case var JSON.object(this) = self else {
            throw JSONError.unableToMergeCases(self, json)
        }
        this.merge(new) { (_, new) -> JSON in new }
        return .object(this)
    }
    
    // MARK: - Sub-Types
    
    public struct CodingKeys: CodingKey {
        public var stringValue: String
        public var intValue: Int?
        
        public init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        public init(intValue: Int) {
            self.init(stringValue: "\(intValue)")
            self.intValue = intValue
        }
    }
    
    // MARK: - Private Helper Coding Methods
    
    private init(from container: KeyedDecodingContainer<JSON.CodingKeys>)throws {
        var object: [String: JSON] = [:]
        
        try container.allKeys.forEach { (key) in
            if let value = try? container.decodeNil(forKey: key), value {
                object[key.stringValue] = .null
            } else if let value = try? container.decode(String.self, forKey: key) {
                object[key.stringValue] = .string(value)
            } else if let value = try? container.decode(Number.self, forKey: key) {
                object[key.stringValue] = .number(value)
            } else if let value = try? container.decode(Bool.self, forKey: key) {
                object[key.stringValue] = .bool(value)
            } else if let con = try? container.nestedContainer(keyedBy: JSON.CodingKeys.self, forKey: key) {
                object[key.stringValue] = try JSON(from: con)
            } else if let con = try? container.nestedUnkeyedContainer(forKey: key) {
                object[key.stringValue] = try JSON(from: con)
            } else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Un-supported type found in JSON")
            }
        }
        
        self = .object(object)
    }
    
    private init(from c: UnkeyedDecodingContainer)throws {
        var container = c
        var array: [JSON] = []
        
        while !container.isAtEnd {
            if let value = try? container.decodeNil(), value {
                array.append(.null)
            } else if let value = try? container.decode(String.self) {
                array.append(.string(value))
            } else if let value = try? container.decode(Number.self) {
                array.append(.number(value))
            } else if let value = try? container.decode(Bool.self) {
                array.append(.bool(value))
            } else if let con = try? container.nestedContainer(keyedBy: JSON.CodingKeys.self) {
                try array.append(JSON(from: con))
            } else if let con = try? container.nestedUnkeyedContainer() {
                try array.append(JSON(from: con))
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Un-supported type found in JSON")
            }
        }
        
        self = .array(array)
    }
    
    private func encode(object: [String: JSON], with c: KeyedEncodingContainer<JSON.CodingKeys>) throws {
        var container = c
        
        try object.forEach({ (key, value) in
            let key = CodingKeys(stringValue: key)
            
            switch value {
            case .null: try container.encodeNil(forKey: key)
            case let .string(value): try container.encode(value, forKey: key)
            case let .number(value): try container.encode(value, forKey: key)
            case let .bool(value): try container.encode(value, forKey: key)
            case let .object(value):
                let con = container.nestedContainer(keyedBy: JSON.CodingKeys.self, forKey: key)
                try encode(object: value, with: con)
            case let .array(value):
                let con = container.nestedUnkeyedContainer(forKey: key)
                try encode(array: value, with: con)
            }
        })
    }
    
    private func encode(array: [JSON], with c: UnkeyedEncodingContainer) throws {
        var container = c
        
        try array.forEach { (element) in
            switch element {
            case .null: try container.encodeNil()
            case let .string(value): try container.encode(value)
            case let .number(value): try container.encode(value)
            case let .bool(value): try container.encode(value)
            case let .object(value):
                let con = container.nestedContainer(keyedBy: JSON.CodingKeys.self)
                try encode(object: value, with: con)
            case let .array(value):
                let con = container.nestedUnkeyedContainer()
                try encode(array: value, with: con)
            }
        }
    }
}
