/* *************************************************************************************************
 SpecificCharacter.swift
   © 2020 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */
 
import Foundation

/// An abstract class that represents a specific character.
public class SpecificCharacter:
  Comparable,
  ExpressibleByExtendedGraphemeClusterLiteral,
  Hashable,
  RawRepresentable
{
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public typealias RawValue = Character
  
  /// Returns a Boolean value that indicates whether this type accept `character` or not.
  public class func expects(_ character: Character) -> Bool { return false }
  
  public final class func ==(lhs: SpecificCharacter, rhs: SpecificCharacter) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  public final class func <(lhs: SpecificCharacter, rhs: SpecificCharacter) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.rawValue)
  }
  
  public private(set) var rawValue: Character
  
  fileprivate init(_validatedCharacter: Character) {
    self.rawValue = _validatedCharacter
  }
  
  public required convenience init?(rawValue: Character) {
    guard Self.expects(rawValue) else { return nil }
    self.init(_validatedCharacter: rawValue)
  }
  
  public required convenience init(extendedGraphemeClusterLiteral: Character) {
    assert(Self.expects(extendedGraphemeClusterLiteral), "Invalid Character.")
    self.init(_validatedCharacter: extendedGraphemeClusterLiteral)
  }
}

public typealias SpaceCharacter = Character.Space
public typealias NewlineCharacter = Character.Newline
extension Character {
  /// Represents a whitespace character excluding new lines.
  public final class Space: SpecificCharacter {
    public override class func expects(_ character: Character) -> Bool {
      return character.isWhitespace && !character.isNewline
    }
    
    /// U+0020
    public static let space: Space = "\u{0020}"
    
    /// U+0009
    public static let horizontalTab: Space = "\t"
  }
  
  /// Represents a newline character.
  public final class Newline: SpecificCharacter {
    public override class func expects(_ character: Character) -> Bool {
      return character.isNewline
    }
    
    /// LF(U+000A)
    public static let lineFeed: Newline = "\u{000A}"
    
    /// CR(U+000D)
    public static let carriageReturn: Newline = "\u{000D}"
    
    /// CR(U+000D)+LF(U+000A)
    public static let carriageReturnAndLineFeed: Newline = "\u{000D}\u{000A}"
  }
}
