import Vapor
import Foundation

extension JSON: LosslessHTTPBodyRepresentable {
    
    /// See `LosslessHTTPBodyRepresentable.convertToHTTPBody()`.
    public func convertToHTTPBody() -> HTTPBody {
        return (try? self.body()) ?? HTTPBody()
    }
    
    /// Converts the `JSON` to an `HTTPBody`.
    ///
    /// - Throws: Encoding errors when converting the `JSON` to `Data`.
    public func body()throws -> HTTPBody {
        return try HTTPBody(data: self.encoded())
    }
    
    /// Creates an `HTTPResponse` with the `JSON` as its body and a `Content-Type: application/json` header.
    ///
    /// - Parameters:
    ///   - status: The HTTP status for the response. Defaults to 200 (OK).
    ///   - headers: Additional headers for the response. Any `Content-Type` headers will be replaced.
    ///
    /// - Throws: Encoding errors when converting the `JSON` to `Data`.
    /// - Returns: An `HTTPResponse` instance with the `JSON` as its body.
    public func response(withStatus status: HTTPStatus = .ok, headers: HTTPHeaders = [:])throws -> HTTPResponse {
        var header = headers
        header.replaceOrAdd(name: .contentType, value: MediaType.json.serialize())
        return try HTTPResponse(status: status, headers: header, body: self.body())
    }
}

extension Response {
    
    /// Creates a `Response` instance with `JSON` as its body.
    ///
    /// - Parameters:
    ///   - container: The container that the `Response` instance lives on.
    ///   - body: The `JSON` for the body of the response.
    ///
    /// - Throws: Encoding errors when converting the `JSON` to `Data`.
    public convenience init(using container: Container, body: JSON)throws {
        self.init(using: container)
        try self.content.encode(body)
    }
}

extension Request {
    
    /// Creates a `Request` instance with `JSON` as its body.
    ///
    /// - Parameters:
    ///   - container: The container that the `Request` instance lives on.
    ///   - body: The `JSON` for the body of the request.
    ///
    /// - Throws: Encoding errors when converting the `JSON` to `Data`.
    public convenience init(using container: Container, body: JSON)throws {
        self.init(using: container)
        try self.content.encode(body)
    }
}
