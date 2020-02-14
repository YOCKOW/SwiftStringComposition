/* *************************************************************************************************
StringCompositionTests.swift
  © 2020 YOCKOW.
    Licensed under MIT License.
    See "LICENSE.txt" for more information.
************************************************************************************************ */


import XCTest
@testable import StringComposition

final class StringLineTests: XCTestCase {
  func test_init() {
    do { // validation
      XCTAssertNotNil(String.Line("\n\nA\n", indentLevel: 0))
      XCTAssertNil(String.Line("\n\nA\nB", indentLevel: 0))
    }
    
    do { // indentation
      let line = String.Line("  Some Line\n", indent: .spaces(count: 2))
      XCTAssertEqual(line?.indentLevel, 1)
      XCTAssertEqual(line?.payload, "Some Line")
      XCTAssertEqual(line?.description(using: .spaces(count: 4)), "    Some Line\n")
    }
  }
  
  func test_indentLevel() {
    var line = String.Line("A")
    XCTAssertEqual(line.indentLevel, 0)
    
    line.indentLevel += 2
    XCTAssertEqual(line.indentLevel, 2)
    
    line.indentLevel = -1
    XCTAssertEqual(line.indentLevel, 0)
  }
  
  func test_description() {
    var line = String.Line("Line")
    XCTAssertEqual(line.description, "Line\n")
    
    line.indentLevel = 2
    XCTAssertEqual(line.description(using: .spaces(count: 4)), "        Line\n")
  }
  
  func test_append() {
    var line = String.Line("  Some", indent: .spaces(count: 2))
    line? += " Line"
    XCTAssertEqual(line?.payload, "Some Line")
  }
}

final class StringCompositionTests: XCTestCase {
  func test_init() throws {
    let string = """
    #include <stdio.h>

    int main(int argc, char* argv[]) {
        printf("Hello, world!");
        return 0;
    }

    """
    
    let lines = String.Composition(string)
    
    enum _Error: Error { case unexpectedCount }
    guard lines.count == 7 else { throw _Error.unexpectedCount }
    XCTAssertEqual(lines.last!.isEmpty, true)
    XCTAssertEqual(lines[3].indentLevel, 1)
    XCTAssertEqual(lines[4].payload, "return 0;")
  }
  
  func test_shift() {
    let string = """
    switch int {
      case 0:
        break
      default:
        return
    }
    """
    
    var lines = String.Composition(string)
    
    XCTAssertEqual(lines[0].indentLevel, 0)
    XCTAssertEqual(lines[1].indentLevel, 1)
    XCTAssertEqual(lines[2].indentLevel, 2)
    XCTAssertEqual(lines[3].indentLevel, 1)
    XCTAssertEqual(lines[4].indentLevel, 2)
    XCTAssertEqual(lines[5].indentLevel, 0)
    
    lines.shiftLeft(1, in: 1...4)
    XCTAssertEqual(lines[0].indentLevel, 0)
    XCTAssertEqual(lines[1].indentLevel, 0)
    XCTAssertEqual(lines[2].indentLevel, 1)
    XCTAssertEqual(lines[3].indentLevel, 0)
    XCTAssertEqual(lines[4].indentLevel, 1)
    XCTAssertEqual(lines[5].indentLevel, 0)
    
    lines.indent = .spaces(count: 4)
    XCTAssertEqual(lines.description, """
    switch int {
    case 0:
        break
    default:
        return
    }
    
    """)
  }
}

