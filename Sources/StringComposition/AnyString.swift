/* *************************************************************************************************
 AnyString.swift
   © 2020 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */
 
import Foundation

private func _mustBeOverridden(function: StaticString = #function,
                               file: StaticString = #file, line: UInt = #line) -> Never {
  fatalError("\(function) must be overridden.")
}

internal struct _AnyString: Comparable,
                            CustomDebugStringConvertible,
                            CustomStringConvertible,
                            Equatable,
                            Hashable {
  private class _StringBox {
    func appending<S>(_ string: S) -> _StringBox where S: StringProtocol { _mustBeOverridden() }
    func compare<S>(_ other: S) -> ComparisonResult where S: StringProtocol { _mustBeOverridden() }
    func compare(_ other: _StringBox) -> ComparisonResult { _mustBeOverridden() }
    var count: Int { _mustBeOverridden() }
    func data(using encoding: String.Encoding, allowLossyConversion: Bool) -> Data? { _mustBeOverridden() }
    var debugDescription: String { _mustBeOverridden() }
    var description: String { _mustBeOverridden() }
    func hash(into hasher: inout Hasher) { _mustBeOverridden() }
    var isEmpty: Bool { _mustBeOverridden() }
    func isEqual<S>(to string: S) -> Bool where S: StringProtocol { _mustBeOverridden() }
    func isEqual(to string: _StringBox) -> Bool { _mustBeOverridden() }
  }
  
  private class _SomeString<T>: _StringBox where T: StringProtocol {
    private var _base: T
    init(_ string: T) {
      self._base = string
    }
    
    override func appending<S>(_ string: S) -> _StringBox where S: StringProtocol {
      return _SomeString<String>(self._base.appending(string))
    }
    
    override func compare<S>(_ other: S) -> ComparisonResult where S: StringProtocol {
      return self._base.compare(other)
    }
    
    override func compare(_ other: _StringBox) -> ComparisonResult {
      let negated = other.compare(self._base)
      switch negated {
      case .orderedSame: return .orderedSame
      case .orderedAscending: return .orderedDescending
      case .orderedDescending: return .orderedAscending
      }
    }
    
    override var count: Int {
      return self._base.count
    }
    
    override func data(using encoding: String.Encoding, allowLossyConversion: Bool) -> Data? {
      return self._base.data(using: encoding, allowLossyConversion: allowLossyConversion)
    }
    
    override var debugDescription: String {
      return String(reflecting: self._base)
    }
    
    override var description: String {
      return String(self._base)
    }
    
    override func hash(into hasher: inout Hasher) {
      hasher.combine(self._base)
    }
    
    override var isEmpty: Bool {
      return self._base.isEmpty
    }
    
    override func isEqual<S>(to string: S) -> Bool where S: StringProtocol {
      return self._base == string
    }
    
    override func isEqual(to string: _StringBox) -> Bool {
      return string.isEqual(to: self._base)
    }
  }
  
  private var _box: _StringBox
  
  init<S>(_ string: S) where S: StringProtocol {
    self._box = _SomeString<S>(string)
  }
  
  static func ==(lhs: _AnyString, rhs: _AnyString) -> Bool {
    return lhs._box.isEqual(to: rhs._box)
  }
  
  static func <(lhs: _AnyString, rhs: _AnyString) -> Bool {
    return lhs._box.compare(rhs._box) == .orderedAscending
  }
  
  mutating func append<S>(_ string: S) where S: StringProtocol {
    self._box = self._box.appending(string)
  }
  
  var count: Int {
    return self._box.count
  }
  
  func data(using encoding: String.Encoding, allowLossyConversion: Bool) -> Data? {
    return self._box.data(using: encoding, allowLossyConversion: allowLossyConversion)
  }
  
  var debugDescription: String {
    return self._box.debugDescription
  }
  
  var description: String {
    return self._box.description
  }
  
  func hash(into hasher: inout Hasher) {
    self._box.hash(into: &hasher)
  }
  
  var isEmpty: Bool {
    return self._box.isEmpty
  }
  
}
