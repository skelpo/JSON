public enum JSONError: Error {
    case unableToMergeCases(JSON, JSON)
    case badPathAtKey([String], String)
    case invalidOperationForStructure(JSON)
}
