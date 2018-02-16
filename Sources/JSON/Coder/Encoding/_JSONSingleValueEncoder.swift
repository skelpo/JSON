import Foundation

extension _JSONEncoder: SingleValueEncodingContainer {
    fileprivate func assertCanEncodeNewValue() {
        precondition(self.canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }
    
    func _encode<T>(_ value: T) where T: SafeJSONRepresentable {
        assertCanEncodeNewValue()
        if self.container != nil {
            self.container.json = value.json
        } else {
            self.container = JSONContainer(json: value.json)
        }
    }
    
    public func encodeNil() throws {
        assertCanEncodeNewValue()
        if self.container != nil {
            self.container.json = .null
        } else {
            self.container = JSONContainer(json: .null)
        }
    }
    
    public func encode(_ value: Bool) throws {
        _encode(value)
    }
    
    public func encode(_ value: Int) throws {
        _encode(value)
    }
    
    public func encode(_ value: String) throws {
        _encode(value)
    }
    
    public func encode(_ value: Float) throws {
        _encode(value)
    }
    
    public func encode(_ value: Double) throws {
        _encode(value)
    }
    
    public func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try value.encode(to: self)
    }
}
