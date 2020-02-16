/* *************************************************************************************************
 StringComposition.swift
   © 2020 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

import Foundation
import Ranges

extension Set where Element == Int {
  fileprivate func _greatestCommonDivisor() -> Int {
    func _gcd(_ i1: Int, _ i2: Int) -> Int {
      assert(i1 > 0 && i2 > 0)
      // Euclidean Algorithm
      var (gg, ll): (Int, Int) = i1 >= i2 ? (i1, i2) : (i2, i1)
      var remain = gg % ll
      while remain != 0 {
        gg = ll
        ll = remain
        remain = gg % ll
      }
      return ll
    }
    
    assert(!self.isEmpty)
    return self.dropFirst().reduce(into: self.first!) { $0 = _gcd($0, $1) }
  }
}

/// Represents a string as a collection of lines.
public typealias StringLines = String.Composition

extension String {
  /// Represents a string as a collection of lines.
  public struct Composition: CustomDebugStringConvertible,
                             CustomStringConvertible,
                             Equatable,
                             Hashable,
                             RandomAccessCollection,
                             RangeReplaceableCollection {
    private var _lines: [String.Line]
    
    /// An indent that is used in `description`.
    public var indent: String.Indent = .default
    
    /// A newline character that is used in `description`.
    public var newline: Character.Newline = .lineFeed
    
    /// A Boolean value that indicates whether the last newline exists or not.
    public var hasLastNewline: Bool = true
    
    /// Creates a empty string.
    public init () {
      self._lines = []
    }
    
    public init<S>(_ elements: S) where S: Sequence, S.Element == String.Line {
      self._lines = .init(elements)
    }
    
    public init(repeating repeatedValue: String.Line, count: Int) {
      self._lines = .init(repeating: repeatedValue, count: count)
    }
    
    private init<S>(_checkedLines: [S], indent: String.Indent?) where S: StringProtocol {
      let makeLine: (S) -> String.Line = (indent != nil) ? { String.Line($0, indent: indent!)! } : { String.Line($0, indentLevel: 0)! }
      
      self._lines = []
      
      if _checkedLines.count == 0 {
        self.hasLastNewline = false
      } else {
        let lastLine = _checkedLines.last!
        self.hasLastNewline = lastLine.isEmpty
        
        let rawLines = self.hasLastNewline ? _checkedLines.dropLast() : _checkedLines
        for rawLine in rawLines {
          self._lines.append(makeLine(rawLine))
        }
      }
    }
    
    public init<S>(_ string: S, indent: String.Indent) where S: StringProtocol {
      self.init(_checkedLines: string.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }),
                indent: indent)
    }
    
    public init<S>(_ string: S, detectIndent: Bool = true) where S: StringProtocol {
      let rawLines = string.split(omittingEmptySubsequences: false) { $0.isNewline }
      
      if !detectIndent {
        self.init(_checkedLines: rawLines, indent: nil)
        return
      }
      
      var spaceTypeCount: [Character: Int] = [:]
      var spaceWidths: [Character: Set<Int>] = [:]
      
      func _found(_ space: Character) {
        if spaceTypeCount.keys.contains(space) {
          spaceTypeCount[space]! += 1
        } else {
          spaceTypeCount[space] = 0
        }
      }
      
      func _countWidth<S>(_ space: Character, in line: S) -> Int where S: StringProtocol {
        assert(!line.isEmpty)
        var ii = line.startIndex
        var result = 0
        while true {
          guard line[ii] == space else { break }
          result += 1
          ii = line.index(after: ii)
        }
        assert(result > 0)
        return result
      }
      
      func _addWidth(_ width: Int, for space: Character) {
        if spaceWidths.keys.contains(space) {
          spaceWidths[space]!.insert(width)
        } else {
          spaceWidths[space] = [width]
        }
      }
      
      do { // scan to detect indent
        for rawLine in rawLines {
          guard let first = rawLine.first, first.isWhitespace else { continue }
          _found(first)
          _addWidth(_countWidth(first, in: rawLine), for: first)
        }
      }
      
      if spaceTypeCount.isEmpty {
        assert(spaceWidths.isEmpty)
        self.init(_checkedLines: rawLines, indent: nil)
        return
      }
      
      let indentSpace = spaceTypeCount.max(by: { $0.value < $1.value })!.key
      let width = spaceWidths[indentSpace]!._greatestCommonDivisor()
      
      self.init(_checkedLines: rawLines,
                indent: String.Indent(SpaceCharacter(rawValue: indentSpace)!, count: width))
    }
    
    public typealias Index = Int
    
    public struct Iterator: IteratorProtocol {
      public typealias Element = String.Line
      
      private var _iterator: Array<String.Line>.Iterator
      fileprivate init(_ composition: String.Composition) {
        self._iterator = composition._lines.makeIterator()
      }
      
      public mutating func next() -> String.Line? {
        return self._iterator.next()
      }
    }
    
    public mutating func append(_ newElement: String.Line) {
      self._lines.append(newElement)
    }
    
    public mutating func append<S>(contentsOf newElements: S) where S: Sequence, S.Element == String.Line {
      self._lines.append(contentsOf: newElements)
    }
    
    public var count: Int {
      return self._lines.count
    }
    
    public func data(using encoding: String.Encoding, allowLossyConversion: Bool = false) -> Data? {
      guard
        let indentData = self.indent.description.data(using: encoding,
                                                      allowLossyConversion: allowLossyConversion)
        else {
          return nil
      }
      
      guard
        let newlineData = "\(self.newline.rawValue)".data(using: encoding,
                                                          allowLossyConversion: allowLossyConversion)
        else {
          return nil
      }

      func _appendIndentData(_ data: inout Data, indentLevel: Int) {
        for _ in 0..<indentLevel { data.append(indentData) }
      }
      
      func _appendPayloadData(_ data: inout Data, line: String.Line) throws {
        enum _Error: Error { case conversionFailure }
        guard
          let payloadData = line._payloadData(using: encoding,
                                              allowLossyConversion: allowLossyConversion)
          else {
            throw _Error.conversionFailure
        }
        data.append(payloadData)
      }
      
      func _appendNewline(_ data: inout Data) {
        data.append(newlineData)
      }
      
      let heuristicCapacity = self._lines.count * 128
      var result = Data(capacity: heuristicCapacity)
      do {
        if self._lines.count > 0 {
          for line in self._lines.dropLast() {
            _appendIndentData(&result, indentLevel: line.indentLevel)
            try _appendPayloadData(&result, line: line)
            _appendNewline(&result)
          }
          let lastLine = self._lines.last!
          _appendIndentData(&result, indentLevel: lastLine.indentLevel)
          try _appendPayloadData(&result, line: lastLine)
          if self.hasLastNewline {
            _appendNewline(&result)
          }
        }
      } catch {
        return nil
      }
      return result
    }
    
    public var debugDescription: String {
      func _log10(_ ii: Int) -> Int { return Int(floor(log10(Double(ii)))) }
      
      let count = self._lines.count
      let nWidths = _log10(count) + 1
      
      var result = ""
      for (ii, line) in self._lines.enumerated() {
        let lineNumber = ii + 1
        let spaces = String(repeating: " ", count: nWidths - _log10(lineNumber) - 1)
        result += "\(spaces)L\(String(lineNumber, radix: 10)). \(line.description(using: self.indent))"
        
        if ii < self._lines.count - 1 || self.hasLastNewline {
          result += "\(self.newline)"
        } else {
          // No newline at the last...
          result += "\u{1F6AB}\n"
        }
      }
      return result
    }
    
    public var description: String {
      var result = self._lines.map({ $0.description(using: self.indent) }).joined(separator: "\(self.newline.rawValue)")
      if self.hasLastNewline { result.append(self.newline.rawValue) }
      return result
    }
    
    public var endIndex: Int {
      return self._lines.endIndex
    }
    
    public func index(after ii: Int) -> Int {
      return self._lines.index(after: ii)
    }
    
    public func index(before ii: Int) -> Int {
      return self._lines.index(before: ii)
    }
    
    public mutating func insert(_ newElement: String.Line, at ii: Int) {
      self._lines.insert(newElement, at: ii)
    }
    
    public mutating func insert<S>(contentsOf newElements: S, at ii: Int) where S: Collection, S.Element == String.Line {
      self._lines.insert(contentsOf: newElements, at: ii)
    }
    
    public func makeIterator() -> String.Composition.Iterator {
      return .init(self)
    }
    
    public var startIndex: Int {
      return self._lines.startIndex
    }
    
    public subscript(position: Int) -> String.Line {
      get {
        return self._lines[position]
      }
      set {
        self._lines[position] = newValue
      }
    }
  }
}

extension String.Composition {
  private enum _Direction: Equatable { case left, right }
  private mutating func _shift<R>( _ direction: _Direction, _ level: Int, in range: R) where R: GeneralizedRange, R.Bound == Index {
    let shift: (inout String.Line) -> Void = (direction == .left) ? { $0.shiftLeft(level) } : { $0.shiftRight(level) }
    for ii in range.relative(to: self._lines) {
      shift(&self._lines[ii])
    }
  }
  
  public mutating func shiftLeft<R>(_ level: Int = 1, in range: R) where R: GeneralizedRange, R.Bound == Index {
    self._shift(.left, level, in: range)
  }
  
  @inlinable
  public mutating func shiftLeft(_ level: Int = 1) {
    self.shiftLeft(level, in: self.startIndex..<self.endIndex)
  }
  
  public mutating func shiftRight<R>(_ level: Int = 1, in range: R) where R: GeneralizedRange, R.Bound == Index {
    self._shift(.right, level, in: range)
  }
  
  @inlinable
  public mutating func shiftRight(_ level: Int = 1) {
    self.shiftRight(level, in: self.startIndex..<self.endIndex)
  }
}
