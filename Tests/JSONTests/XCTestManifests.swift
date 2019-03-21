#if !canImport(ObjectiveC)
import XCTest

extension JSONCodingTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__JSONCodingTests = [
        ("testDecodeNestedJSONSpeed", testDecodeNestedJSONSpeed),
        ("testDecodingNestedJSON", testDecodingNestedJSON),
        ("testDecodingSpeed", testDecodingSpeed),
        ("testDefaultJSONEDecoding", testDefaultJSONEDecoding),
        ("testDefaultJSONEncoding", testDefaultJSONEncoding),
        ("testEncodeNestedJSONSpeed", testEncodeNestedJSONSpeed),
        ("testEncodingNestedJSON", testEncodingNestedJSON),
        ("testEncodingSpeed", testEncodingSpeed),
        ("testFailableJSONSpeed", testFailableJSONSpeed),
        ("testFromJSON", testFromJSON),
        ("testJSONDecoding", testJSONDecoding),
        ("testJSONEncoding", testJSONEncoding),
        ("testJSONInitJSON", testJSONInitJSON),
        ("testSingleValueEncodingFailure", testSingleValueEncodingFailure),
        ("testSmallData", testSmallData),
        ("testToJSON", testToJSON),
    ]
}

extension JSONTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__JSONTests = [
        ("testAssociatedValueProperties", testAssociatedValueProperties),
        ("testDynamicAccessGet", testDynamicAccessGet),
        ("testDynamicAccessSetSpeed", testDynamicAccessSetSpeed),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JSONCodingTests.__allTests__JSONCodingTests),
        testCase(JSONTests.__allTests__JSONTests),
    ]
}
#endif
