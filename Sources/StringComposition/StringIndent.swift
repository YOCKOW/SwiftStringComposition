/* *************************************************************************************************
 StringIndent.swift
   © 2020,2024 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */
 
import Foundation

extension String {
  public struct Indent: Comparable,
                        CustomStringConvertible,
                        Equatable,
                        Hashable,
                        Sendable {
    public var character: Character.Space
    
    /// Returns an instance of `Indent` that represents the space whose widths is `count`.
    public static func spaces(count: Int) -> Indent { return .init(.space, count: count) }
    
    /// Returns an instance of `Indent` that represents the horizontal tabs.
    public static func tabs(count: Int) -> Indent { return .init(.horizontalTab, count: count) }
    
    /// Default indent.
    public static let `default`: Indent = .spaces(count: 2)
    
    private var _count: Int = 0
    public var count: Int {
      get {
        return self._count
      }
      set {
        self._count = newValue > 0 ? newValue : 0
      }
    }
    
    public init(_ character: Character.Space, count: Int) {
      self.character = character
      self.count = count
    }

    public var description: String {
      return String(repeating: self.character.rawValue, count: self.count)
    }

    public func description(indentLevel: Int) -> String {
      precondition(indentLevel >= 0)
      return String(repeating: self.character.rawValue, count: indentLevel * self.count)
    }
    
    public static func <(lhs: Indent, rhs: Indent) -> Bool {
      return lhs.description < rhs.description
    }
  }
}

extension StringProtocol where SubSequence == Substring {
  /// Returns a Boolean value indicating whether the string begins with the specified indent.
  internal func _hasIndent(_ indent: String.Indent) -> Bool {
    return self.hasPrefix(indent.description)
  }
  
  internal func _dropIndentWithCounting(_ indent: String.Indent) -> (Self.SubSequence, count: Int) {
    var count: Int = 0
    var string: Self.SubSequence = self[self.startIndex..<self.endIndex]
    while true {
      if !string._hasIndent(indent) { break }
      count += 1
      string = string.dropFirst(indent.count)
    }
    return (string, count)
  }
  
  internal func _dropIndent(_ indent: String.Indent) -> Self.SubSequence? {
    let droppedAndCount = self._dropIndentWithCounting(indent)
    return droppedAndCount.count > 0 ? droppedAndCount.0 : nil
  }
  
  internal func _indentLevel(for indent: String.Indent) -> Int {
    return self._dropIndentWithCounting(indent).count
  }
}
