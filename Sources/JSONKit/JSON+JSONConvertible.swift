extension String: JSONRepresentable {
    public var json: JSON {
        return .string(self)
    }
}
