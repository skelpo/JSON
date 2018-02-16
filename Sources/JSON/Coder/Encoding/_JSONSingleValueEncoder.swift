import Foundation

internal final class _JSONSingleValueEncoder: SingleValueEncodingContainer {
    var codingPath: [CodingKey]
    var container: JSONContainer
    
    init(at codingPath: [CodingKey], wrapping container: JSONContainer) {
        self.codingPath = codingPath
        self.container = container
    }
    
    func _encode<T>(_ value: T) where T: SafeJSONRepresentable {
        self.container = JSONContainer(json: value.json)
    }
    
    public func encodeNil() throws {
        _encode(JSON.null)
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
        let encoder = _JSONEncoder(codingPath: self.codingPath)
        try value.encode(to: encoder)
        self.container.json = encoder.container.json
    }
}
