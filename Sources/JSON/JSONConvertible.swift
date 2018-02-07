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
