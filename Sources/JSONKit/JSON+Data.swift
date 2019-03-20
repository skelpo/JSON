import Foundation

extension JSON {
    
    /// Decodes a `JSON` instance from `Data` with a `JSONDecoder`.
    ///
    /// - Parameter data: The JSON data to decode to a `JSON` instance.
    /// - Throws: Decoding errors when converting the `Data` passed in to `JSON`.
    public init(data: Data) throws {
        self = try JSONDecoder().decode(JSON.self, from: data)
    }
    
    /// Converts `JSON` to `Data` using a `JSONEncoder`.
    ///
    /// - Throws: Encoding errors when converting `JSON` to `Data`.
    public func encoded()throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
