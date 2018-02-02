public enum JSON: Codable {
    case null
    case string(String)
    case number(Number)
    case bool(Bool)
    indirect case array([JSON])
    indirect case object([String: JSON])
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JSON.CodingKeys.self) {
            self = try JSON(from: container)
        } else if let container = try? decoder.unkeyedContainer() {
            self = try JSON(from: container)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [], debugDescription: "No top-level object or array found"))
        }
    }
    
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
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
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
}
