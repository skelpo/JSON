import Vapor
import JSON

extension JSONError: AbortError {
    public var status: HTTPResponseStatus {
        return .internalServerError
    }
    
    public var reason: String {
        switch self {
        case let .badPathAtKey(path, key): return "No element for key " +  key + " at path " + path.joined(separator: ".")
        case let .unableToMergeCases(first, second): return "Unable to combine values " + first.description + " and " + second.description
        case let .invalidOperationForStructure(json): return "Attempted operation is not valid for JSON structure " + json.description
        }
    }
    
    public var identifier: String {
        switch self {
        case .badPathAtKey: return "badJSONPath"
        case .unableToMergeCases: return "invalidOperation"
        case .invalidOperationForStructure: return "invalidOperation"
        }
    }
}
