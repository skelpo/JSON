/// A wrapper for standard numeric types.
public enum Number: Codable, Hashable, CustomStringConvertible {
    
    /// Wraps an `Int` instance.
    case int(Int)
    
    /// Wraps a `Float` instance.
    case float(Float)
    
    /// Wraps a `Double` instance.
    case double(Double)
    
    /// See `Decodable.init(from:)`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let float = try? container.decode(Float.self) {
            self = .float(float)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "No number type found")
        }
    }
    
    /// See `Encodable.encode(to:)`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .int(int): try container.encode(int)
        case let .float(float): try container.encode(float)
        case let .double(double): try container.encode(double)
        }
    }
    
    /// See `CustomStringConvertible.description`.
    public var description: String {
        switch self {
        case let .int(int): return String(describing: int)
        case let .float(float): return String(describing: float)
        case let .double(double): return String(describing: double)
        }
    }
}

extension Number: ExpressibleByIntegerLiteral {
    
    /// See `ExpressibleByIntegerLiteral.init(integerLiteral:)`.
    ///
    /// Allows you to create an instance of `Number` with a `Int` literal:
    ///
    ///     let number: Number = 42 // Number.int(42)
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension Number: ExpressibleByFloatLiteral {
    
    /// See `ExpressibleByFloatLiteral.init(floatLiteral:)`.
    ///
    /// Allows you to create an instance of `Number` from a `Float` literal. The float type used is `Double`.
    ///
    ///     let number: Number = 3.1415
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}
