/* *************************************************************************************************
 StringLine.swift
   © 2020,2024 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */
 
import Foundation
import yExtensions

/// Represents one line of string.
public typealias StringLine = String.Line

private extension StringProtocol where SubSequence == Substring {
  var _forcedSubstring: Substring {
    return self[self.startIndex..<self.endIndex]
  }
  
  func _trimmed() -> Substring {
    guard let firstIndex = self.firstIndex(where: { !$0.isNewline }) else {
      return self._forcedSubstring
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
                      Hashable,
                      Sendable {
    public typealias StringLiteralType = String
    
    private var _line: Substring
    
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
    
    public static let empty = String.Line("", indentLevel: 0)!
    
    private init<S>(_validatedLine: S, indentLevel: Int) where S: StringProtocol, S.SubSequence == Substring {
      self._line = _validatedLine._forcedSubstring
      self.indentLevel = indentLevel
    }
    
    /// Initialize with a string.
    /// `line` should contain only one line.
    public init?<S>(_ line: S, indentLevel: Int = 0) where S: StringProtocol, S.SubSequence == Substring {
      let trimmed = line._trimmed()
      guard _validate(trimmed) else { return nil }
      self.init(_validatedLine: trimmed, indentLevel: indentLevel)
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
    public init?<S>(_ line: S, indent: String.Indent) where S: StringProtocol, S.SubSequence == Substring {
      let (raw, level) = line._trimmed()._dropIndentWithCounting(indent)
      self.init(raw, indentLevel: level)
    }
    
    public static func ==(lhs: String.Line, rhs: String.Line) -> Bool {
      return lhs.indentLevel == rhs.indentLevel && lhs._line == rhs._line
    }
    
    public static func += <S>(lhs: inout String.Line, rhs: S) where S: StringProtocol, S.SubSequence == Substring {
      let trimmed = rhs._trimmed()
      precondition(_validate(trimmed), "Given string is not a single line.")
      lhs._line.append(contentsOf: trimmed)
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
    
    public func description(
      using indent: String.Indent,
      omitSpacesIfPayloadIsEmpty empty: Bool = false
    ) -> String {
      if empty && self._line.isEmpty {
        return ""
      }
      return indent.description(indentLevel: self.indentLevel) + self._line.description
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(self._line)
    }
    
    public var isEmpty: Bool {
      return self.indentLevel == 0 && self._line.isEmpty
    }
    
    public func isEqual<S>(to string: S, indent: String.Indent? = nil) -> Bool where S: StringProtocol {
      if let indent = indent {
        return self.description(using: indent) == string
      } else {
        return self.payloadProperties.isEqual(to: string)
      }
    }
    
    public var payload: String {
      get {
        return self._line.description
      }
      set {
        let trimmed = newValue._trimmed()
        guard _validate(trimmed) else { fatalError("Given string is not a single line.") }
        self._line = trimmed
      }
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

extension String.Line {
  public var payloadProperties: PayloadProperties {
    return .init(self)
  }
  
  /// Wrapper of properties about `payload`.
  public struct PayloadProperties {
    private let _payload: Substring
    fileprivate init(_ line: String.Line) {
      self._payload = line._line
    }
    
    public func data(using encoding: String.Encoding, allowLossyConversion: Bool = false) -> Data? {
      return self._payload.data(using: encoding, allowLossyConversion: allowLossyConversion)
    }
    
    /// String width when it is drawn using `East_Asian_Width` property.
    /// See also `var estimatedWidth: Int { get }` of `Character` in `yExtensions`.
    public var estimatedWidth: Int {
      return self._payload.estimatedWidth
    }
    
    public func isEqual<S>(to string: S) -> Bool where S: StringProtocol {
      return self._payload == string
    }
    
    public var length: Int {
      return self._payload.count
    }
  }
}
