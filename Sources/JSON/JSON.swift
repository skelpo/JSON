// @dynamicMemberLookup
public enum JSON: Codable, Equatable {
    
    // MARK: - Cases
    case null
    case string(String)
    case number(Number)
    case bool(Bool)
    indirect case array([JSON])
    indirect case object([String: JSON])

    // MARK: - Public Methods
    public subscript(dynamicMember member: String) -> JSON {
        switch self {
        case let .object(structure): return structure[member] ?? .null
        default: return .null
        }
    }
    
    public subscript(_ key: String...) -> JSON? {
        do {
            return try self.element(at: key)
        } catch {
            return nil
        }
    }
    
    public subscript(_ index: Int) -> JSON? {
        switch self {
        case let .array(sequence):
            guard index < self.count! && index >= 0 else {
                return nil
            }
            return sequence[index]
        default: return nil
        }
    }
    
    public mutating func insert(_ json: JSON, at index: Int)throws {
        switch self {
        case var .array(sequence):
            sequence.insert(json, at: index)
            self = .array(sequence)
        default: throw JSONError.unableToMergeCases(self, json)
        }
    }
    
    public mutating func append(_ json: JSON)throws {
        switch self {
        case var .array(sequence):
            sequence.append(json)
            self = .array(sequence)
        default: throw JSONError.unableToMergeCases(self, json)
        }
    }
    
    public mutating func append(_ json: FailableJSONRepresentable)throws {
        try self.append(json.failableJSON())
    }
    
    public mutating func set(_ key: String, _ json: JSON)throws {
        switch self {
        case var .object(structure):
            structure[key] = json
            self = .object(structure)
        default: throw JSONError.unableToMergeCases(self, json)
        }
    }
    
    public mutating func set(_ key: String, to json: FailableJSONRepresentable)throws {
        try self.set(key, json.failableJSON())
    }
    
    public func merge(_ json: JSON)throws -> JSON {
        guard case let JSON.object(new) = json, case var JSON.object(this) = self else {
            throw JSONError.unableToMergeCases(self, json)
        }
        this.merge(new) { (_, new) -> JSON in new }
        return .object(this)
    }
    
    public func element(at path: [String])throws -> JSON {
        var current: JSON = self
        
        try path.forEach { (key) in
            switch current {
            case .object: current = try current.getSingleLevelElement(with: key)
            case .array: current = try current.getElementsFromArray(with: key)
            default: throw JSONError.badPathAtKey(path, key)
            }
        }
        
        return current
    }
    
    public var count: Int? {
        switch self {
        case let .array(sequence): return sequence.count
        case let .object(structure): return structure.count
        default: return nil
        }
    }
}
