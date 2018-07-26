public enum Number: Codable, Equatable, CustomStringConvertible {
    case int(Int)
    case float(Float)
    case double(Double)
    
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .int(int): try container.encode(int)
        case let .float(float): try container.encode(float)
        case let .double(double): try container.encode(double)
        }
    }
    
    public var description: String {
        switch self {
        case let .int(int): return String(describing: int)
        case let .float(float): return String(describing: float)
        case let .double(double): return String(describing: double)
        }
    }
}

extension Number: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension Number: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}
