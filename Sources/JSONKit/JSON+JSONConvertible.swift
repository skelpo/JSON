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
