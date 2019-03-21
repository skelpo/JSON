/// A representation of ambigious JSON.
///
/// # Heterogeneous Arrays.
///
/// Take for exmaple the JSON below:
///
///     {
///         "users": [
///             {
///                 "age": 18,
///                 "name": {
///                     "first": "Caleb",
///                     "last": "Kleveter"
///                 }
///             }
///         ],
///         "metadata": [42, 3.14, true, "fizz buzz"]
///     }
///
/// The `users` data is pretty normal, but the `metadata` array can't be represented by standard arrays.
///
/// The `metadata` array, when decoded to a `JSON` instance, will result in this case:
///
///     JSON.array([.number(.int(42)), .number(.double(3.14)), .bool(true), .string("fizz buzz")])
///
/// # Value Unwrapping
///
/// Getting the associated value from an enum case can be a real pain,
/// so there are properties for each case to unwrap the value.
///
/// If you have the example JSON above, it is an `.object` case.
/// You can use the `.object` property to get the `[String: JSON]` value it wraps:
///
///     json.object // [String: JSON]?
///
/// There are also properties for `.null`, `.string`, `.bool`, `.int`, `.float`, `.double`, and `.array`.
/// Be sure to read the docs for the `.null` property.
///
/// These properties also have setters. They let you set the value of the current `JSON` case.
/// They will set the case regardless the current type, so if the case is a `.bool`,
/// you can use `.string` and the case will be changed to a `.string` case.
///
///     var json = JSON.bool(true)
///     json.string = "Fizz Buzz"
///     print(json) // "\"Fizz Buzz\""
///
/// # Dynamic Access
///
/// `JSON` supports `@dynamicMemberLookup`, so it is really easy to access values your JSON objects/arrays:
///
///     let firstname = json.users.0.name.first.string
///
/// This also works for setting JSON values:
///
///     json.users.address.city = "Cupertion"
@dynamicMemberLookup
public enum JSON: Equatable, CustomStringConvertible {
    
    // MARK: - Properties
    
    /// Gets the value of a `.null` case.
    ///
    /// You will always get `nil` from this property. This is because the
    /// JSON case is itself `.null`, or it isn't so conversion failed and you get `nil`.
    ///
    /// The `Wrapped` type is `Never` so the compiler can gurantee that the value is `nil`.
    public var null: Optional<Never> {
        get { return nil }
        set { self = .null }
    }
    
    /// Accesses the value of a `.bool` case.
    ///
    /// The setter will set the JSON case regardles the current type.
    public var bool: Bool? {
        get {
            guard case let .bool(value) = self else { return nil }
            return value
        }
        set {
            self = newValue.map(JSON.bool) ?? .null
        }
    }
    
    /// Accesses the value of a `.string` case.
    ///
    /// The setter will set the JSON case regardles the current type.
    public var string: String? {
        get {
            guard case let .string(value) = self else { return nil }
            return value
        }
        set {
            self = newValue.map(JSON.string) ?? .null
        }
    }
    
    /// Accesses the value of a `Number.int` case wrapped in a `.number` case.
    ///
    /// The setter will set the JSON case regardles the current type.
    public var int: Int? {
        get {
            guard case let .number(.int(value)) = self else { return nil }
            return value
        }
        set {
            self = newValue.map(Number.int).map(JSON.number) ?? .null
        }
    }
    
    /// Accesses the value of a `Number.float` case wrapped in a `.number` case.
    ///
    /// The setter will set the JSON case regardles the current type.
    public var float: Float? {
        get {
            guard case let .number(.float(value))  = self else { return nil }
            return value
        }
        set {
            self = newValue.map(Number.float).map(JSON.number) ?? .null
        }
    }
    
    /// Accesses the value of a `Number.double` case wrapped in a `.number` case.
    ///
    /// The setter will set the JSON case regardles the current type.
    public var double: Double? {
        get {
            guard case let .number(.double(value)) = self else { return nil }
            return value
        }
        set {
            self = newValue.map(Number.double).map(JSON.number) ?? .null
        }
    }
    
    /// Accesses the value of an `.array` case.
    ///
    /// The setter will set the JSON case regardles the current type.
    public var array: [JSON]? {
        get {
            guard case let .array(value) = self else { return nil }
            return value
        }
        set {
            self = newValue.map(JSON.array) ?? .null
        }
    }
    
    /// Accesses the value of an `.object` case.
    ///
    /// The setter will set the JSON case regardles the current type.
    public var object: [String: JSON]? {
        get {
            guard case let .object(value) = self else { return nil }
            return value
        }
        set {
             self = newValue.map(JSON.object) ?? .null
        }
    }
    
    /// Converts a non-optiona JSON case to an optional JSON case.
    ///
    /// If the JSON case is `.null`, then `nil` will be returned. Otherwise the JSON case is returned.
    /// This allows you to unwrap a case to make sure it isn't `null`:
    ///
    ///     if let value = json.optional {
    ///         // ...
    ///     }
    public var optional: Optional<JSON> {
        switch self {
        case .null: return nil
        default: return self
        }
    }
    
    // MARK: - Cases
    
    /// A `null` JSON value.
    ///
    /// This represents an explicit `null` value in the JSON. A non-existant key or index has no representation.
    ///
    ///     {
    ///         "foo": null
    ///     }
    case null
    
    /// A boolean JSON value.
    ///
    ///     {
    ///         "fizz": true,
    ///         "buzz": false
    ///     }
    case bool(Bool)
    
    /// A string JSON value.
    ///
    ///     {
    ///         "foo": "bar"
    ///     }
    case string(String)
    
    /// A number JSON value.
    ///
    /// This case wraps a `Number` enum case, which will be an int, float, or double.
    ///
    ///     {
    ///         "answer": 42,
    ///         "pi": 3.1415
    ///     }
    case number(Number)
    
    /// A JSON array of values.
    ///
    ///     [
    ///         "foo",
    ///         "bar",
    ///         1997,
    ///     ]
    case array([JSON])
    
    /// A JSON object which maps string keys to JSON values.
    ///
    ///     {
    ///         "foo: "bar",
    ///         "fizz": true,
    ///         "bar": [98, 97, 114]
    ///     }
    case object([String: JSON])
    
    
    // MARK: - Initializers
    
    /// Creates a `JSON` instance with the `.null` case.
    public init() {
        self = .null
    }
    
    /// Creates a `JSON` instance with the `.string` case.
    ///
    /// - Parameter string: The `String` held by the `.string` case.
    public init(_ string: String) {
        self = .string(string)
    }
    
    /// Creates a `JSON` instance with the `.bool` case.
    ///
    /// - Parameter bool: The `Bool` held by the `.bool` case.
    public init(_ bool: Bool) {
        self = .bool(bool)
    }
    
    /// Creates a `JSON` instance with the `.number(Number.int)` case.
    ///
    /// - Parameter int: The `Int` held by the `.int` case.
    public init(_ int: Int) {
        self = .number(.int(int))
    }
    
    /// Creates a `JSON` instance with the `.number(Number.float)` case.
    ///
    /// - Parameter float: The `Float` held by the `.float` case.
    public init(_ float: Float) {
        self = .number(.float(float))
    }
    
    /// Creates a `JSON` instance with the `.number(Number.double)` case.
    ///
    /// - Parameter double: The `Double` held by the `.double` case.
    public init(_ double: Double) {
        self = .number(.double(double))
    }
    
    /// Creates a `JSON` instance with the `.array` case.
    ///
    /// - Parameter array: The `JSON` values held by the `.array` case.
    public init(_ array: [JSON]) {
        self = .array(array)
    }
    
    /// Creates a `JSON` instance with the `.object` case.
    ///
    /// - Parameter array: The `JSON` key/values map held by the `.object` case.
    public init(_ object: [String: JSON]) {
        self = .object(object)
    }
    
    // MARK: - Public Methods
    
    /// Gets the JSON value for a given key.
    ///
    /// - Complexity: _O(n)_, where _n_ is the number of elements in the JSON array you are accessing object values from.
    ///   More often though, you are accessing object values via key, and that is _O(1)_.
    ///
    /// Most of the time, the member passed in with be a `String` key. This will get a value for an object key:
    ///
    ///     json.user.first_name // .string("Tanner")
    ///
    /// However, `Int` members are also supported in that case of a `JSON` array:
    ///
    ///     json.users.0.age // .number(.int(42))
    ///
    /// - Parameter member: The key for JSON objects or index for JSON arrays of the value to get.
    ///
    /// - Returns: The JSON value for the given key or index. `.null` is returned if the value is not found or
    ///   the JSON value this subscript is called on does not have nested data, i.e. `.string`, `.bool`, etc.
    public subscript(dynamicMember member: String) -> JSON {
        get {
            switch self {
            case let .object(structure): return structure[member] ?? .null
            case let .array(sequence) where Int(member) != nil:
                if let index = Int(member) {
                    guard index >= 0 && index < sequence.endIndex else { return .null }
                    return sequence[index]
                } else {
                    let elements = sequence.map { element in element[dynamicMember: member] }
                    return .array(elements)
                }
            default: return .null
            }
        }
        set {
            switch self {
            case var .object(structure):
                structure[member] = newValue
                self = .object(structure)
            case var .array(sequence) where Int(member) != nil:
                guard let index = Int(member) else { return }
                sequence[index] = newValue
                self = .array(sequence)
            default: self = newValue
            }
        }
    }
    
    /// Accesses the `JSON` value at a given key/index path.
    ///
    /// - Complexity: _O(n * m)_ where _n_ is the number of elements in the path and _m_ is
    ///   the amount of elements in the array you are accessing element properties from.
    ///
    /// To get the value, `.get(_:)` is used. To set the value, `.set(_:to:)` is used.
    ///
    /// - Parameter path: The key/index path to access.
    /// - Returns: Thw JSON value(s) found at the path passed in.
    public subscript (path: String...) -> JSON {
        get {
            return self.get(path)
        }
        set {
            self.set(path, to: newValue)
        }
    }
    
    /// Gets the JSON at a given path.
    ///
    /// - Complexity: _O(n * m)_ where _n_ is the number of elements in the path and _m_ is
    ///   the amount of elements in the array you are accessing element properties from.
    ///
    /// Depending on the JSON case for the path element, different logic paths will be taken:
    /// - `.object`: Get the JSON value where the key is equal to the path element.
    /// - `.array`:
    ///   - `Int`: Get the array element at the given index.
    ///   - `String`: Get the value for the key from each array element, and return them as an array.
    /// - default: Return `.null`.
    ///
    /// - Parameter path: The keys and indexes to the desired JSON value(s).
    /// - Returns: Thw JSON value(s) found at the path passed in. You will get a `.null` case
    ///   if no JSON is found at the given path.
    public func get(_ path: [String]) -> JSON {
        return path.reduce(self) { json, key in
            switch json {
            case let .object(object): return object[key] ?? .null
            case let .array(array):
                if let index = Int(key) {
                    return array[index]
                } else {
                    let new = array.map { element in
                        return element.get([key])
                    }
                    return .array(new)
                }
            default: return .null
            }
        }
    }
    
    /// Sets the value of an object key or array index.
    ///
    /// - Complexity: _O(n)_, where _n_ is the number of elements in the `path`. This method is
    ///   recursive, so you may have adverse performance for long paths.
    ///
    /// - Parameters:
    ///   - path: The path of the value to set.
    ///   - json: The JSON value to set the index or key to.
    public mutating func set<Path>(_ path: Path, to json: JSON) where Path: Collection, Path.Element == String {
        if let key = path.first {
            var current = self.get([key])
            current.set(path.dropFirst(), to: json)
            self = current
        } else {
            self = json
        }
    }
    
    /// See `CustomStringConvertible.description`.
    ///
    /// This textal representation is compressed, so you might need to prettify it to read it.
    public var description: String {
        switch self {
        case .null: return "null"
        case let .string(string): return "\"" + string + "\""
        case let .number(number): return number.description
        case let .bool(bool): return bool.description
        case let .array(array): return "[" + array.map { $0.description }.joined(separator: ",") + "]"
        case let .object(object):
            let data = object.map { "\"" + $0.key + "\":" + $0.value.description }.joined(separator: ",")
            return "{" + data + "}"
        }
    }
}
