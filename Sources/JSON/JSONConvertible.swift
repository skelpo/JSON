// MARK: - Protocols

/// A protocol composed of `SafeJSONRepresentable`, `FailableJSONRepresentable`, and `LosslessJSONConvertible`.
public typealias JSONRepresentable = SafeJSONRepresentable & FailableJSONRepresentable & LosslessJSONConvertible

/// A type that can be converted to a `JSON` instance without any loss or errors.
public protocol SafeJSONRepresentable {
    
    /// The `JSON` representation of the instance.
    ///
    ///     42.json // JSON.number(Number.int(42))
    var json: JSON { get }
}

/// A type that can be converted to a `JSON` instance, with potential errors.
public protocol FailableJSONRepresentable {
    
    /// Gets the `JSON` representation of the instance.
    ///
    /// - Throws: Failures to convert one of the instance's values to a `JSON` representation.
    /// - Returns: The `JSON` structure that represents the instance.
    func failableJSON()throws -> JSON
}

/// A type that can be initialized from `JSON` losslessly.
public protocol LosslessJSONConvertible {
    
    /// Creates an instance of `Self` from the `JSON` instance passed in.
    ///
    /// If initialization fails at any point, `nil` will be returned.
    init?(json: JSON)
}

// MARK: - Default Converters

extension FailableJSONRepresentable where Self: SafeJSONRepresentable {
    
    /// The default implementation of `FailableJSONRepresentable.failableJSON()` for
    /// type that conform to `SafeJSONRepresentable`.
    ///
    /// - Throws: This implementation never throws.
    /// - Returns: `self.json`
    public func failableJSON()throws -> JSON {
        return self.json
    }
}
