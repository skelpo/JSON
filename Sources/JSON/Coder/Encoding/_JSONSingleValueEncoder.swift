import Foundation

internal final class _JSONSingleValueEncoder: SingleValueEncodingContainer {
    var codingPath: [CodingKey]
    var container: JSONContainer
    
    init(at codingPath: [CodingKey], wrapping container: JSONContainer) {
        self.codingPath = codingPath
        self.container = container
    }
    
    func _encode<T>(_ value: T) where T: SafeJSONRepresentable {
        self.container.json = value.json
    }
    
    func encodeNil()             throws { _encode(JSON.null) }
    func encode(_ value: Bool)   throws { _encode(value) }
    func encode(_ value: Int)    throws { _encode(value) }
    func encode(_ value: String) throws { _encode(value) }
    func encode(_ value: Float)  throws { _encode(value) }
    func encode(_ value: Double) throws { _encode(value) }

    func encode(_ value: Int8)   throws { _encode(value) }
    func encode(_ value: Int16)  throws { _encode(value) }
    func encode(_ value: Int32)  throws { _encode(value) }
    func encode(_ value: Int64)  throws { _encode(value) }
    func encode(_ value: UInt8)  throws { _encode(value) }
    func encode(_ value: UInt16) throws { _encode(value) }
    func encode(_ value: UInt32) throws { _encode(value) }
    func encode(_ value: UInt64) throws { _encode(value) }

    func encode<T : Encodable>(_ value: T) throws {
        let encoder = _JSONEncoder(codingPath: self.codingPath)
        try value.encode(to: encoder)
        self.container.json = encoder.container.json
    }
}
