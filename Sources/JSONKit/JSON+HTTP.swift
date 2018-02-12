import HTTP
import Foundation

extension JSON: HTTPBodyRepresentable {
    public func makeBody() throws -> HTTPBody {
        return try HTTPBody(JSONEncoder().encode(self))
    }
}
