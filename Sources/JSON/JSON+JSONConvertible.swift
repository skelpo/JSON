extension JSON: JSONRepresentable {
    public var json: JSON {
        return self
    }
}

extension Optional: JSONRepresentable where Wrapped: JSONRepresentable {
    public var json: JSON {
        switch self {
        case .none: return .null
        case let .some(value): return value.json
        }
    }
}

extension String: JSONRepresentable {
    public var json: JSON {
        return .string(self)
    }
}

extension Int: JSONRepresentable {
    public var json: JSON {
        return .number(.int(self))
    }
}

extension Float: JSONRepresentable {
    public var json: JSON {
        return .number(.float(self))
    }
}

extension Double: JSONRepresentable {
    public var json: JSON {
        return .number(.double(self))
    }
}

extension Bool: JSONRepresentable {
    public var json: JSON {
        return .bool(self)
    }
}

extension Array: JSONRepresentable where Element: JSONRepresentable {
    public var json: JSON {
        return .array(self.map({ $0.json }))
    }
}

extension Dictionary: JSONRepresentable where Key == String, Value: JSONRepresentable {
    public var json: JSON {
        return .object(self.reduce(into: [:], { (data, element) in
            data[element.key] = element.value.json
        }))
    }
}
