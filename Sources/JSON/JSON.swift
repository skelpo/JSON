public enum JSON: Codable {
    case null
    case string(String)
    case number(Number)
    case bool(Bool)
    indirect case array([JSON])
    indirect case object([String: JSON])
    
    public struct CodingKeys: CodingKey {
        public var stringValue: String
        public var intValue: Int?
        
        public init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        public init?(intValue: Int) {
            self.init(stringValue: "\(intValue)")
            self.intValue = intValue
        }
    }
}
