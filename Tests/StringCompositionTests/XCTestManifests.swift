#if !canImport(ObjectiveC)
import XCTest

extension StringCompositionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StringCompositionTests = [
        ("test_append", test_append),
        ("test_data", test_data),
        ("test_equality", test_equality),
        ("test_init", test_init),
        ("test_shift", test_shift),
        ("test_subsequence", test_subsequence),
    ]
}

extension StringLineTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StringLineTests = [
        ("test_append", test_append),
        ("test_description", test_description),
        ("test_equality", test_equality),
        ("test_estimatedWidth", test_estimatedWidth),
        ("test_indentLevel", test_indentLevel),
        ("test_init", test_init),
        ("test_length", test_length),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StringCompositionTests.__allTests__StringCompositionTests),
        testCase(StringLineTests.__allTests__StringLineTests),
    ]
}
#endif
