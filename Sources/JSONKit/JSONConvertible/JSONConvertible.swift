import CodableKit
import Vapor
import JSON

protocol JSONConvertible {
    var json: JSON { get }
    
    init(json: JSON)
}
