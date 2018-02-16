import Foundation

internal final class _JSONEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var container: JSONContainer!
    
    init(codingPath: [CodingKey] = [], json: JSONContainer? = nil) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.container = json
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if self.container == nil { self.container = JSONContainer(json: [:]) }
        precondition(self.container.isObject, "JSON must have an object structure")
        
        let container = _JSONKeyedEncoder<Key>(at: self.codingPath, wrapping: self.container)
        return .init(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if self.container == nil { self.container = JSONContainer(json: []) }
        precondition(self.container.isArray, "JSON must have an array structure")
        
        return _JSONUnkeyedEncoder(at: self.codingPath, wrapping: self.container)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        if self.container == nil { self.container = JSONContainer(json: .null) }
        return _JSONSingleValueEncoder(at: self.codingPath, wrapping: self.container)
    }
    
    static func encode<T>(_ t: T)throws -> JSON where T: Encodable {
        let encoder = _JSONEncoder()
        try t.encode(to: encoder)
        return encoder.container.json
    }
}

internal final class JSONContainer {
    var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var isObject: Bool {
        return self.json.isObject
    }
    
    var isArray: Bool {
        return self.json.isArray
    }
    
    func value<T>(`for` type: T.Type, at path: [CodingKey])throws -> T where T: Decodable {
        return try self.json.value(for: type, at: path)
    }
    
    public func insert(_ json: JSON, at index: Int)throws {
        try self.json.insert(json, at: index)
    }
    
    public func append(_ json: JSON)throws {
        try self.json.append(json)
    }
    
    public func append(_ json: FailableJSONRepresentable)throws {
        try self.json.append(json)
    }
    
    public func set(_ key: String, _ json: JSON)throws {
        try self.json.set(key, json)
    }
    
    public func set(_ key: String, to json: FailableJSONRepresentable)throws {
        try self.json.set(key, to: json)
    }
    
    public func merge(_ json: JSON)throws -> JSON {
        return try self.json.merge(json)
    }
    
    public func element(at path: [String])throws -> JSON {
        return try self.json.element(at: path)
    }
    
    public var count: Int? {
        return self.json.count
    }
}
