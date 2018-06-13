import Foundation

extension JSON {
    public var isObject: Bool {
        switch self {
        case .object: return true
        default: return false
        }
    }
    
    public var isArray: Bool {
        switch self {
        case .array: return true
        default: return false
        }
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
    
    fileprivate func number<T: SignedInteger>(at path: [CodingKey], as type: T.Type)throws -> T {
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
    
    fileprivate func number<T: BinaryFloatingPoint>(at path: [CodingKey], as type: T.Type)throws -> T {
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
