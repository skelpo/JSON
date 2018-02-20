public func <=<T>(property: inout T, value: T?) {
    guard let value = value else {
        return
    }
    property = value
}
