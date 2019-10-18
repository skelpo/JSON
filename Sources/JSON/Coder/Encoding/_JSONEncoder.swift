import Foundation

internal final class _JSONEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var container: JSONContainer!
    
    init(codingPath: [CodingKey] = [], json: JSONContainer? = nil) {
        self.codingPath = codingPath
        self.container = json
        self.userInfo = [:]
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if self.container == nil { self.container = JSONContainer(json: [:]) }
        let container = _JSONKeyedEncoder<Key>(for: self, path: self.codingPath)
        return .init(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if self.container == nil { self.container = JSONContainer(json: []) }
        return _JSONUnkeyedEncoder(for: self, path: self.codingPath)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        if self.container == nil { self.container = JSONContainer(json: .null) }
        return _JSONSingleValueEncoder(for: self, path: self.codingPath)
    }
    
    static func encode<T>(_ t: T)throws -> JSON where T: Encodable {
        if let json = try? (t as? FailableJSONRepresentable)?.failableJSON() {
            return json
        } else {
            let encoder = _JSONEncoder()
            try t.encode(to: encoder)
            return encoder.container.json
        }
    }
}

internal final class JSONContainer {
    var json: JSON

    init(json: JSON) {
        self.json = json
    }

    func assign(path: [String] = [], key: String, to value: JSON) {
        self.json.set(path + [key], to: value)
    }

    func assign(path: [String] = [], to value: JSON) {
        switch self.json.get(path) {
        case var .array(elements):
            elements.append(value)
            self.json.set(path, to: .array(elements))
        default:
            self.json.set(path, to: value)
        }
    }
}
