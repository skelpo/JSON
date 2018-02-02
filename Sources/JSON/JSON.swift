public enum JSON {
    case null
    case string(String)
    case number(Number)
    case bool(Bool)
    indirect case array([JSON])
}
