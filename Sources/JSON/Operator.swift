public func <=<T>(property: inout T, value: T?) {
    guard let value = value else {
        return
    }
    property = value
}

public func <=<T>(property: inout T, value: JSON?)throws where T: Decodable {
    try property <= T(json: value)
}
