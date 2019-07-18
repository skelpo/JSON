extension JSON: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return self
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        self = json
    }
}

extension Optional: JSONRepresentable where Wrapped: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        switch self {
        case .none: return .null
        case let .some(value): return value.json
        }
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        switch json {
        case .null: self = nil
        default: self = Wrapped(json: json)
        }
    }
}

extension String: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .string(self)
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.string else { return nil }
        self = string
    }
}

extension Int: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .number(.int(self))
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.int else { return nil }
        self = string
    }
}

extension Float: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .number(.float(self))
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.float else { return nil }
        self = string
    }
}

extension Double: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .number(.double(self))
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.double else { return nil }
        self = string
    }
}

extension Bool: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .bool(self)
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let string = json.bool else { return nil }
        self = string
    }
}

extension Array: JSONRepresentable where Element: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .array(self.map { $0.json })
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let array = json.array else { return nil }
        self = array.compactMap(Element.init(json:))
    }
}

extension Dictionary: JSONRepresentable where Key == String, Value: JSONRepresentable {
    
    /// See `SafeJSONRepresentable.json`.
    public var json: JSON {
        return .object(self.reduce(into: [:]) { data, element in data[element.key] = element.value.json })
    }
    
    /// See `LosslessJSONConvertible.init(json:)`.
    public init?(json: JSON) {
        guard let object = json.object else { return nil }
        self = object.reduce(into: [:]) { result, pair in
            if let value = Value(json: pair.value) {
                result[pair.key] = value
            }
        }
    }
}

extension FixedWidthInteger {
    public var json: JSON {
        return .number(.int(Int(self)))
    }

    public init?(json: JSON) {
        guard let int = json.int else { return nil }
        self.init(int)
    }
}

extension Int8: JSONRepresentable { }
extension Int16: JSONRepresentable { }
extension Int32: JSONRepresentable { }
extension Int64: JSONRepresentable { }
extension UInt8: JSONRepresentable { }
extension UInt16: JSONRepresentable { }
extension UInt32: JSONRepresentable { }
extension UInt64: JSONRepresentable { }
