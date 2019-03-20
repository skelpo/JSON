/// Converts between `JSON` and other `Codable` types.
public final class JSONCoder {
    
    /// Converts an `Encodable` type to a `JSON` instance
    ///
    /// - Parameter t: The `Encodable` value to convert.
    ///
    /// - Throws: Encoding errors that occur when encoding the `Encoodable` type to `JSON`.
    /// - Returns: The `JSON` that represents the `Encodable` value.
    public static func encode<T>(_ t: T)throws -> JSON where T: Encodable {
        return try _JSONEncoder.encode(t)
    }
    
    /// Converts a `JSON` instance to a `Decoable` type.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to create from the `JSON`.
    ///   - json: The `JSON` instance to convert to type `T`.
    ///
    /// - Throws: Decoding errors that occur when decoding `JSON` to `T`.
    /// - Returns: An instance of `T` created from the `JSON` instance passed in.
    public static func decode<T>(_ type: T.Type, from json: JSON)throws -> T where T: Decodable {
        if type is JSON.Type {
            return json as! T
        }
        return try _JSONDecoder.decode(type, from: json)
    }
}

extension Decodable {
    
    /// Initializes an instance of `Self` from a `JSON` instance using `JSONCoder`.
    ///
    /// - Parameter json: The `JSON` to create an instance of `Self` from.
    /// - Throws: Decoding errors that occur when decoding `JSON` to `Self`.
    public init(json: JSON)throws {
        self = try JSONCoder.decode(Self.self, from: json)
    }
    
    /// Initializes an instance of `Self` from a `JSON` instance using `JSONCoder`.
    ///
    /// Returns `nil` if `nil` is passed in.
    ///
    /// - Parameter json: The `JSON` to create an instance of `Self` from.
    /// - Throws: Decoding errors that occur when decoding `JSON` to `Self`.
    public init?(json: JSON?)throws {
        guard let json = json else { return nil }
        self = try JSONCoder.decode(Self.self, from: json)
    }
}

extension Encodable {
    
    /// Converts an instance of `Self` to `JSON`.
    ///
    /// - Throws: Encoding errors that occur when encoding `Self` to `JSON`.
    /// - Returns: The `JSON` representation of `Self`.
    public func json()throws -> JSON {
        return try JSONCoder.encode(self)
    }
}
