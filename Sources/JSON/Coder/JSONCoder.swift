public final class JSONCoder {
    public static func encode<T>(_ t: T)throws -> JSON where T: Encodable {
        return try _JSONEncoder.encode(t)
    }
    
    public static func decode<T>(_ type: T.Type, from json: JSON)throws -> T where T: Decodable {
        return try _JSONDecoder.decode(type, from: json)
    }
}

extension Decodable {
    public init(json: JSON)throws {
        self = try JSONCoder.decode(Self.self, from: json)
    }
    
    public init?(json: JSON?)throws {
        guard let json = json else { return nil }
        self = try JSONCoder.decode(Self.self, from: json)
    }
}

extension Encodable {
    public func json()throws -> JSON {
        return try JSONCoder.encode(self)
    }
}
