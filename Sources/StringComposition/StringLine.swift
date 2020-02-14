/* *************************************************************************************************
 StringLine.swift
   © 2020 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */
 
public typealias StringLine = String.Line

extension StringProtocol {
  fileprivate func _trimmed() -> Self.SubSequence {
    guard let firstIndex = self.firstIndex(where: { !$0.isNewline }) else {
      return self[self.endIndex..<self.endIndex]
    }
    return self[firstIndex...self.lastIndex(where: { !$0.isNewline })!]
  }
}

private func _validate<S>(_ expectedToBeSingleLine: S) -> Bool where S: StringProtocol {
  return expectedToBeSingleLine.allSatisfy { !$0.isNewline }
}

extension String {
  /// Represents one line of string.
  public struct Line: Comparable,
                      CustomDebugStringConvertible,
                      CustomStringConvertible,
                      Equatable,
                      ExpressibleByStringInterpolation,
                      Hashable {
    public typealias StringLiteralType = String
    
    private var _line: _AnyString
    
    private var _indentLevel: Int = 0
    public var indentLevel: Int {
      get {
        return self._indentLevel
      }
      set {
        self._indentLevel = newValue > 0 ? newValue : 0
      }
    }
    
    public static func <(lhs: Line, rhs: Line) -> Bool {
      // "    Line" < "  Line" < "  Lion"
      if lhs._indentLevel > rhs._indentLevel { return true }
      if lhs._indentLevel < rhs._indentLevel { return false }
      return lhs._line < rhs._line
    }
    
    public init?<S>(_ line: S, indentLevel: Int = 0) where S: StringProtocol {
      let trimmed = line._trimmed()
      guard _validate(trimmed) else { return nil }
      self._line = _AnyString(trimmed)
      self.indentLevel = indentLevel
    }
    
    public init(stringLiteral value: Self.StringLiteralType) {
      guard let validLine = Line(value) else { fatalError("Given string is not a single line.") }
      self = validLine
    }
    
    /// Initialize with a string which is expected to have the specified indent.
    /// 
    /// ```Swift
    /// let line = String.Line("  Some Line", indent: .spaces(2))!
    /// print(line.indentLevel) // -> Prints "1"
    /// print(line.rawLine) // -> Prints "Some Line"
    /// print(line.description(with: .spaces(4))) // -> Prints "    Some Line\n"
    /// ```
    public init?<S>(_ line: S, indent: String.Indent) where S: StringProtocol {
      let (raw, level) = line._trimmed()._dropIndentWithCounting(indent)
      self.init(raw, indentLevel: level)
    }
    
    public static func ==(lhs: String.Line, rhs: String.Line) -> Bool {
      return lhs.indentLevel == rhs.indentLevel && lhs._line == rhs._line
    }
    
    public static func += <S>(lhs: inout String.Line, rhs: S) where S: StringProtocol {
      lhs._line.append(rhs)
    }
    
    public var debugDescription: String {
      return "Indent Level: \(self.indentLevel), Line: \(self._line.debugDescription)"
    }
    
    public var description: String {
      return self.description(using: .default)
    }
    
    public func description(using indent: String.Indent) -> String {
      return indent.description(indentLevel: self.indentLevel) + self._line.description + "\n"
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(self._line)
    }
    
    public var isEmpty: Bool {
      return self.indentLevel == 0 && self._line.isEmpty
    }
    
    public var payload: String {
      get {
        return self._line.description
      }
      set {
        let trimmed = newValue._trimmed()
        guard _validate(trimmed) else { fatalError("Given string is not a single line.") }
        self._line = _AnyString(trimmed)
      }
    }
  }
}

extension String.Line {
  private mutating func _shift(_ level: Int) {
    self.indentLevel += level
  }
  
  public mutating func shiftLeft(_ level: Int = 1) {
    self.indentLevel -= level
  }
  
  public mutating func shiftRight(_ level: Int = 1) {
    self._shift(level)
  }
}

