import Foundation

// MARK: - Protocols

public typealias JSONRepresentable = SafeJSONRepresentable & FailableJSONRepresentable

public protocol SafeJSONRepresentable {
    var json: JSON { get }
}

public protocol FailableJSONRepresentable {
    func failableJSON()throws -> JSON
}

// MARK: - Default Converters

extension FailableJSONRepresentable where Self: SafeJSONRepresentable {
    public func failableJSON()throws -> JSON {
        return self.json
    }
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
