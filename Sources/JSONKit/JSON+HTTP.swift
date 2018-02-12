import HTTP
import Foundation

extension JSON: HTTPBodyRepresentable {
    public func makeBody() throws -> HTTPBody {
        return try HTTPBody(JSONEncoder().encode(self))
    }
}

extension JSON {
    func response(withStatus status: HTTPStatus = .ok, headers: HTTPHeaders = [:])throws -> HTTPResponse {
        var header = headers
        header[.contentType] = "application/json"
        return try HTTPResponse(status: status, headers: header, body: self)
    }
}
