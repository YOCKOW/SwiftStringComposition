/* *************************************************************************************************
 StringLine.swift
   © 2020 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */
 
import Foundation

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
    /// print(line.payload) // -> Prints "Some Line"
    /// print(line.description(with: .spaces(4))) // -> Prints "    Some Line"
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
    
    /// The number of characters when the default indent is used.
    public var count: Int {
      return self.count(with: .default)
    }
    
    /// The number of characters when the specified `indent` is used.
    public func count(with indent: String.Indent) -> Int {
      return indent.count * self.indentLevel + self._line.count
    }
    
    public var debugDescription: String {
      return "Indent Level: \(self.indentLevel), Line: \(self._line.debugDescription)"
    }
    
    public var description: String {
      return self.description(using: .default)
    }
    
    public func description(using indent: String.Indent) -> String {
      return indent.description(indentLevel: self.indentLevel) + self._line.description
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
    
    internal func _payloadData(using encoding: String.Encoding, allowLossyConversion: Bool) -> Data? {
      return self._line.data(using: encoding, allowLossyConversion: allowLossyConversion)
    }
    
    /// The length of payload.
    ///
    /// The returned value is equal to `payload.count`, however, this property may be slightly faster.
    public var payloadLength: Int {
      return self._line.count
    }
  }
}

extension String.Line {
  @inlinable
  public mutating func shiftLeft(_ level: Int = 1) {
    self.indentLevel -= level
  }
  
  @inlinable
  public mutating func shiftRight(_ level: Int = 1) {
    self.indentLevel += level
  }
}

