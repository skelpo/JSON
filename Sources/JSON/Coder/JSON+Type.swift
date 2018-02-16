import Foundation

extension JSON {
    var isObject: Bool {
        guard case JSON.object = self else {
            return false
        }
        return true
    }
    
    var isArray: Bool {
        guard case JSON.array = self else {
            return false
        }
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
            guard case let JSON.number(number) = self else {
                throw error
            }
            guard case let Number.int(value) = number else {
                throw error
            }
            return value as! T
        case is Float.Type:
            guard case let JSON.number(number) = self else {
                throw error
            }
            guard case let Number.float(value) = number else {
                throw error
            }
            return value as! T
        case is Double.Type:
            guard case let JSON.number(number) = self else {
                throw error
            }
            guard case let Number.double(value) = number else {
                throw error
            }
            return value as! T
        case is String.Type:
            guard case let JSON.string(value) = self else {
                throw error
            }
            return value as! T
        default: return try _JSONDecoder.decode(T.self, from: json)
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
