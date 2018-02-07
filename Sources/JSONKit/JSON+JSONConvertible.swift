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
