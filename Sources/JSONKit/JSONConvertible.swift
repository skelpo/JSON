import Foundation

public protocol JSONRepresentable {
    var json: JSON { get }
}

public protocol FailableJSONRepresentable {
    func json()throws -> JSON
}

extension Decodable {
    public init(json: JSON)throws {
        self = try JSONDecoder().decode(Self.self, from: json.encoded())
    }
}

extension Encodable {
    public func json()throws -> JSON {
        return try JSONDecoder().decode(JSON.self, from: JSONEncoder().encode(self))
    }
}
