import Foundation

internal final class _JSONSingleValueEncoder: SingleValueEncodingContainer {
    let encoder:_JSONEncoder
    var codingPath: [CodingKey]
    
    init(for encoder: _JSONEncoder, path: [CodingKey]? = nil) {
        self.encoder = encoder
        self.codingPath = path ?? encoder.codingPath
    }
    
    func _encode<T>(_ value: T) where T: SafeJSONRepresentable {
        self.encoder.container.assign(path: self.codingPath.map { $0.stringValue }, to: value.json)
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
    func encode(_ value: Decimal) throws { _encode(value) }

    func encode<T : Encodable>(_ value: T) throws {
        try value.encode(to: self.encoder)
    }
}
