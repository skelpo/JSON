extension JSON: ExpressibleByNilLiteral {
    
    /// Creates a `JSON` instance with the `.null` case.
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSON: ExpressibleByStringLiteral {
    
    /// Creates a `JSON` instance with the `.string` case.
    ///
    /// - Parameter value: The `String` wrapped by the `.string` case.
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    
    /// Creates a `JSON` instance with the `.number(Number.int)` case.
    ///
    /// - Parameter value: The `Int` wrapped by the `.int` case.
    public init(integerLiteral value: Int) {
        self = .number(.int(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    
    /// Creates a `JSON` instance with the `.number(Number.double)` case.
    ///
    /// - Parameter value: The `Double` wrapped by the `.double` case.
    public init(floatLiteral value: Double) {
        self = .number(.double(value))
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    
    /// Creates a `JSON` instance with the `.bool` case.
    ///
    /// - Parameter value: The `Bool` wrapped by the `.bool` case.
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    
    /// Creates a `JSON` instance with the `.array` case.
    ///
    /// - Parameter elements: The array elements, which will be converted to their `JSON` representation,
    ///   wrapped by the `.array` case.
    public init(arrayLiteral elements: SafeJSONRepresentable...) {
        self = .array(elements.map { $0.json })
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    
    /// Creates a `JSON` instance with the `.array` case.
    ///
    /// - Parameter elements: The dictionary key/value pairs wrapped in the `.object` case,
    ///   with the values converted to their `JSON` representations.
    public init(dictionaryLiteral elements: (String, SafeJSONRepresentable)...) {
        let structure: [String: JSON] = elements.reduce(into: [:]) { dict, element in dict[element.0] = element.1.json }
        self = .object(structure)
    }
}

