import Vapor
import Foundation

extension JSON {
    func body()throws -> HTTPBody {
        return try HTTPBody(data: JSONEncoder().encode(self))
    }
    
    func response(withStatus status: HTTPStatus = .ok, headers: HTTPHeaders = [:])throws -> HTTPResponse {
        var header = headers
        header.replaceOrAdd(name: .contentType, value: "application/json")
        return try HTTPResponse(status: status, headers: header, body: self.body())
    }
}
