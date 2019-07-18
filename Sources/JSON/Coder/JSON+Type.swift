import Foundation

extension JSON {

    /// Indicates whether this case is a `.null`.
    public var isNull: Bool {
        guard case .null = self else { return false }
        return true
    }

    /// Indicates whether this case is a `.bool`.
    public var isBool: Bool {
        guard case .bool = self else { return false }
        return true
    }

    /// Indicates whether this case is a `.string`.
    public var isString: Bool {
        guard case .string = self else { return false }
        return true
    }

    /// Indicates whether this case is a `.number`.
    public var isNumber: Bool {
        guard case .number = self else { return false }
        return true
    }

    /// Indicates whether this case is a `.number(.int)`.
    public var isInt: Bool {
        guard case let .number(num) = self, case .int = num else { return false }
        return true
    }

    /// Indicates whether this case is a `.number(.float)`.
    public var isFloat: Bool {
        guard case let .number(num) = self, case .float = num else { return false }
        return true
    }

    /// Indicates whether this case is a `.number(.double)`.
    public var isDouble: Bool {
        guard case let .number(num) = self, case .double = num else { return false }
        return true
    }

    /// Indicates whether the case is a`.object`.
    public var isObject: Bool {
        guard case .object = self else { return false }
        return true
    }
    
    /// Indicates whether the case is an`.array`.
    public var isArray: Bool {
        guard case .array = self else { return false }
        return true
    }

    func value<T>(`for` type: T.Type, at path: [CodingKey])throws -> T where T: Decodable {
        let error = DecodingError.expectedType(T.self, at: path, from: self)
        
        switch type {
        case is Bool.Type:
            guard case let JSON.bool(value) = self else {
                throw error
            }
            return value as! T
        case is Int.Type:
            return try self.number(at: path, as: Int.self) as! T
        case is Float.Type:
            return try self.number(at: path, as: Float.self) as! T
        case is Double.Type:
            return try self.number(at: path, as: Double.self) as! T
        case is String.Type:
            guard case let JSON.string(value) = self else {
                throw error
            }
            return value as! T
        default: return try _JSONDecoder.decode(T.self, from: json)
        }
    }
    
    internal func number<T: FixedWidthInteger>(at path: [CodingKey], as type: T.Type)throws -> T {
        let error = DecodingError.expectedType(T.self, at: path, from: self)

        guard case let JSON.number(number) = self else {
            throw error
        }
        
        switch number {
        case let .int(value): return T.init(value)
        case let .float(value): return T.init(value)
        case let .double(value): return T.init(value)
        }
    }
    
    internal func number<T: BinaryFloatingPoint>(at path: [CodingKey], as type: T.Type)throws -> T {
        let error = DecodingError.expectedType(T.self, at: path, from: self)
        
        guard case let JSON.number(number) = self else {
            throw error
        }
        
        switch number {
        case let .int(value): return T.init(value)
        case let .float(value): return T.init(value)
        case let .double(value): return T.init(value)
        }
    }
}

extension DecodingError {
    static func expectedType<T>(_ type: T.Type, at path: [CodingKey], from json: JSON) -> DecodingError {
        return DecodingError.typeMismatch(
            T.self,
            DecodingError.Context(codingPath: path, debugDescription: "Cannot get type \(T.self) from JSON \(json)")
        )
    }
}
