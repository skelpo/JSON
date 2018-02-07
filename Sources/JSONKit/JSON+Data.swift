import Foundation

extension JSON {
    public init(data: Data) throws {
        self = try JSONDecoder().decode(JSON.self, from: data)
    }
    
    public func encoded()throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
