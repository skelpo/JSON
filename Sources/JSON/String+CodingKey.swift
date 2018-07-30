extension String: CodingKey {
    public init?(stringValue: String) {
        self = stringValue
    }
    
    public init?(intValue: Int) {
        self = String(describing: intValue)
    }
    
    public var stringValue: String {
        return self
    }
    
    public var intValue: Int? {
        return Int(self)
    }
}
