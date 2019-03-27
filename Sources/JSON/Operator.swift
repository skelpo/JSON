/// Assigns the value of an optional to a property if it exists.
///
/// - Parameters:
///   - property: The value to set.
///   - value: The optional to set the `property` with.
public func <=<T>(property: inout T, value: T?) {
    guard let value = value else {
        return
    }
    property = value
}

/// Assigns an instance of `T` to a property of type `T` if an instance
/// of `T` can be created from a `JSON` instance.
///
/// - Parameters:
///   - property: The property to set.
///   - value: The `JSON` to convert to `T` and assign to `property`.
/// - Throws: Decoding errors when converting the `JSON` instance to `T`.
public func <=<T>(property: inout T, value: JSON?)throws where T: Decodable {
    try property <= T(json: value)
}
