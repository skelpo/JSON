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

extension JSON {
    public init(dictionaryLiteral elements: (String, SafeJSONRepresentable)...) {
        let structure: [String: JSON] = elements.reduce(into: [:]) { (dict, element) in
            dict[element.0] = element.1.json
        }
        self = .object(structure)
    }
}

