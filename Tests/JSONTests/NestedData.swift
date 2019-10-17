let nestedJSON = """
{
  "age" : 42,
  "name" : {
    "first" : "Ceicl",
    "last" : "Doohickey"
  }
}
"""

struct NestedUser: Codable, Equatable {
    let age: Int
    let firstName: String
    let lastName: String

    static let `default`: NestedUser = NestedUser(age: 42, firstName: "Ceicl", lastName: "Doohickey")

    init(age: Int, firstName: String, lastName: String) {
        self.age = age
        self.firstName = firstName
        self.lastName = lastName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.age = try container.decode(Int.self, forKey: .age)

        let name = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .name)
        self.firstName = try name.decode(String.self, forKey: .first)
        self.lastName = try name.decode(String.self, forKey: .last)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.age, forKey: .age)

        var name = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .name)
        try name.encode(self.firstName, forKey: .first)
        try name.encode(self.lastName, forKey: .last)
    }

    enum CodingKeys: String, CodingKey {
        case age
        case first
        case last
        case name
    }
}
