/* *************************************************************************************************
StringCompositionTests.swift
  © 2020,2024 YOCKOW.
    Licensed under MIT License.
    See "LICENSE.txt" for more information.
************************************************************************************************* */

import Foundation
@testable import StringComposition

#if swift(>=6) && canImport(Testing)
import Testing

@Suite final class StringLineTests {
  @Test func test_init() {
    do { // validation
      #expect(String.Line("\n\nA\n", indentLevel: 0) != nil)
      #expect(String.Line("\n\nA\nB", indentLevel: 0) == nil)
    }

    do { // indentation
      let line = String.Line("  Some Line\n", indent: .spaces(count: 2))
      #expect(line?.indentLevel == 1)
      #expect(line?.payload == "Some Line")
      #expect(line?.description(using: .spaces(count: 4)) == "    Some Line")
    }
  }

  @Test func test_indentLevel() {
    var line = String.Line("A")
    #expect(line.indentLevel == 0)

    line.indentLevel += 2
    #expect(line.indentLevel == 2)

    line.indentLevel = -1
    #expect(line.indentLevel == 0)
  }

  @Test func test_description() {
    var line = String.Line("Line")
    #expect(line.description == "Line")

    line.indentLevel = 2
    #expect(line.description(using: .spaces(count: 4)) == "        Line")
  }

  @Test func test_equality() {
    #expect(String.Line("Some Line").isEqual(to: "Some Line"))
    #expect(String.Line("Some Line", indentLevel: 1)!.isEqual(to: "  Some Line", indent: .spaces(count: 2)))
  }

  @Test func test_append() {
    var line = String.Line("  Some", indent: .spaces(count: 2))
    line? += " Line"
    #expect(line?.payload == "Some Line")
  }

  @Test func test_estimatedWidth() {
    let line = String.Line("  日本🇯🇵は英語でJapan", indent: .spaces(count: 2))
    #expect(line?.payloadProperties.estimatedWidth == 19)
  }

  @Test func test_length() {
    let line = String.Line("      とある文字列の行\n", indent: .spaces(count: 2))
    #expect(line?.payloadProperties.length == 8)
    #expect(line?.count(with: .spaces(count: 4)) == 20)
  }
}

@Suite final class StringCompositionTests {
  @Test func test_init() throws {
    let string = """
    #include <stdio.h>

    int main(int argc, char* argv[]) {
        printf("Hello, world!");
        return 0;
    }

    """

    let lines = String.Composition(string)

    enum _Error: Error { case unexpectedCount }
    guard lines.count == 6 else { throw _Error.unexpectedCount }
    #expect(lines.hasLastNewline)
    #expect(lines[3].indentLevel == 1)
    #expect(lines[4].payload == "return 0;")

    do {
      // Check indent-only line
      let string = """
      First
        Second
          
          Under the empty line.
      """
      let lines = String.Composition(string)
      #expect(lines[2].payload.isEmpty)
      #expect(lines[2].indentLevel == 2)
    }
  }

  @Test func test_equality() {
    var lines = String.Composition("")
    #expect(lines.description == "")

    lines = String.Composition("\n")
    #expect(lines.description == "\n")

    lines = String.Composition("\n\n")
    #expect(lines.description == "\n\n")

    lines = String.Composition("\nA\n")
    #expect(lines.description == "\nA\n")

    lines = String.Composition("A\n")
    #expect(lines.description == "A\n")
  }

  @Test func test_subsequence() {
    let lines = String.Composition("""
      Line 0
      Line 1
      Line 2
      Line 3
      Line 4
      Line 5
      Line 6
      Line 7
      Line 8
      Line 9
      """)

    let lines3to7 = lines[3..<7]
    #expect(lines3to7.hasLastNewline)
    #expect(lines3to7.count == 4)
    #expect(lines3to7.startIndex == 3)
    #expect(lines3to7.endIndex == 7)
    #expect(lines3to7[5].payload == "Line 5")
  }

  @Test func test_append() {
    var lines = String.Composition("Line 0")
    lines.indent = .spaces(count: 2)
    lines.newline = .lineFeed

    lines.append("Line 1", indentLevel: 1)
    #expect(
      lines.description ==
      """
      Line 0
        Line 1
      """
    )

    lines.append(String.Line("Line 2", indentLevel: 1)!, increasingIndentLevel: 1)
    #expect(
      lines.description ==
      """
      Line 0
        Line 1
          Line 2
      """
    )
  }

  @Test func test_shift() {
    let string = """
    switch int {
      case 0:
        break
      default:
        return
    }
    """

    var lines = String.Composition(string)

    #expect(lines[0].indentLevel == 0)
    #expect(lines[1].indentLevel == 1)
    #expect(lines[2].indentLevel == 2)
    #expect(lines[3].indentLevel == 1)
    #expect(lines[4].indentLevel == 2)
    #expect(lines[5].indentLevel == 0)

    lines.shiftLeft(1, in: 1...4)
    #expect(lines[0].indentLevel == 0)
    #expect(lines[1].indentLevel == 0)
    #expect(lines[2].indentLevel == 1)
    #expect(lines[3].indentLevel == 0)
    #expect(lines[4].indentLevel == 1)
    #expect(lines[5].indentLevel == 0)

    lines.indent = .spaces(count: 4)
    #expect(
      lines.description ==
      """
      switch int {
      case 0:
          break
      default:
          return
      }
      """
    )
  }

  @Test func test_data() {
    let string = """
    ABC
      DEF
    """
    var lines = String.Composition(string)
    lines.indent = .spaces(count: 2)

    let data = lines.data(using: .utf8)
    #expect(
      data == Data([
      0x41, 0x42, 0x43, 0x0A,
      0x20, 0x20, 0x44, 0x45, 0x46
      ])
    )
  }
}

#else
import XCTest

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
      XCTAssertEqual(line?.description(using: .spaces(count: 4)), "    Some Line")
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
    XCTAssertEqual(line.description, "Line")
    
    line.indentLevel = 2
    XCTAssertEqual(line.description(using: .spaces(count: 4)), "        Line")
  }
  
  func test_equality() {
    XCTAssertTrue(String.Line("Some Line").isEqual(to: "Some Line"))
    XCTAssertTrue(String.Line("Some Line", indentLevel: 1)!.isEqual(to: "  Some Line", indent: .spaces(count: 2)))
  }
  
  func test_append() {
    var line = String.Line("  Some", indent: .spaces(count: 2))
    line? += " Line"
    XCTAssertEqual(line?.payload, "Some Line")
  }
  
  func test_estimatedWidth() {
    let line = String.Line("  日本🇯🇵は英語でJapan", indent: .spaces(count: 2))
    XCTAssertEqual(line?.payloadProperties.estimatedWidth, 19)
  }
  
  func test_length() {
    let line = String.Line("      とある文字列の行\n", indent: .spaces(count: 2))
    XCTAssertEqual(line?.payloadProperties.length, 8)
    XCTAssertEqual(line?.count(with: .spaces(count: 4)), 20)
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
    guard lines.count == 6 else { throw _Error.unexpectedCount }
    XCTAssertTrue(lines.hasLastNewline)
    XCTAssertEqual(lines[3].indentLevel, 1)
    XCTAssertEqual(lines[4].payload, "return 0;")
    
    do {
      // Check indent-only line
      let string = """
      First
        Second
          
          Under the empty line.
      """
      let lines = String.Composition(string)
      XCTAssertTrue(lines[2].payload.isEmpty)
      XCTAssertEqual(lines[2].indentLevel, 2)
    }
  }
  
  func test_equality() {
    var lines = String.Composition("")
    XCTAssertEqual(lines.description, "")
    
    lines = String.Composition("\n")
    XCTAssertEqual(lines.description, "\n")
    
    lines = String.Composition("\n\n")
    XCTAssertEqual(lines.description, "\n\n")
    
    lines = String.Composition("\nA\n")
    XCTAssertEqual(lines.description, "\nA\n")
    
    lines = String.Composition("A\n")
    XCTAssertEqual(lines.description, "A\n")
  }
  
  func test_subsequence() {
    let lines = String.Composition("""
      Line 0
      Line 1
      Line 2
      Line 3
      Line 4
      Line 5
      Line 6
      Line 7
      Line 8
      Line 9
      """)
    
    let lines3to7 = lines[3..<7]
    XCTAssertTrue(lines3to7.hasLastNewline)
    XCTAssertEqual(lines3to7.count, 4)
    XCTAssertEqual(lines3to7.startIndex, 3)
    XCTAssertEqual(lines3to7.endIndex, 7)
    XCTAssertEqual(lines3to7[5].payload, "Line 5")
  }
  
  func test_append() {
    var lines = String.Composition("Line 0")
    lines.indent = .spaces(count: 2)
    lines.newline = .lineFeed
    
    lines.append("Line 1", indentLevel: 1)
    XCTAssertEqual(lines.description, """
      Line 0
        Line 1
      """)
    
    lines.append(String.Line("Line 2", indentLevel: 1)!, increasingIndentLevel: 1)
    XCTAssertEqual(lines.description, """
    Line 0
      Line 1
        Line 2
    """)
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
  
  func test_data() {
    let string = """
    ABC
      DEF
    """
    var lines = String.Composition(string)
    lines.indent = .spaces(count: 2)
    
    let data = lines.data(using: .utf8)
    XCTAssertEqual(data, Data([
      0x41, 0x42, 0x43, 0x0A,
      0x20, 0x20, 0x44, 0x45, 0x46
    ]))
  }
}
#endif
