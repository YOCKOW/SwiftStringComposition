/* *************************************************************************************************
 SpecificCharacter.swift
   © 2020 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */
 

/// A type that represents a specific character.
/// This protocol is declared as `public`, but is for internal use.
public protocol SpecificCharacter:
  Comparable,
  ExpressibleByExtendedGraphemeClusterLiteral,
  Hashable,
  RawRepresentable
  where  Self.ExtendedGraphemeClusterLiteralType == Character, Self.RawValue == Character
{
  static func expects(_ character: Character) -> Bool
}

extension SpecificCharacter {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  public static func <(lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

  public static func <=(lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue <= rhs.rawValue
  }

  public static func >(lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue > rhs.rawValue
  }

  public static func >=(lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue >= rhs.rawValue
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.rawValue)
  }
}

private protocol _SpecificCharacter: SpecificCharacter {
  override var rawValue: Character { get set }
  init(validatedCharacter: Character)
}

extension _SpecificCharacter {
  public init?(rawValue: Character) {
    guard Self.expects(rawValue) else { return nil }
    self.init(validatedCharacter: rawValue)
  }

  public init(extendedGraphemeClusterLiteral value: Character) {
    assert(Self.expects(value), "Invalid character for this type.")
    self.init(validatedCharacter: value)
  }
}


public typealias SpaceCharacter = Character.Space
extension Character {
  /// Represents a whitespace character excluding new lines.
  public struct Space: SpecificCharacter, _SpecificCharacter {
    public static func expects(_ character: Character) -> Bool {
      return character.isWhitespace && !character.isNewline
    }

    /// U+0020
    public static let space: Space = "\u{0020}"

    /// U+0009
    public static let horizontalTab: Space = "\t"

    public fileprivate(set) var rawValue: Character

    init(validatedCharacter: Character) {
      assert(Space.expects(validatedCharacter))
      self.rawValue = validatedCharacter
    }
  }
}

public typealias NewlineCharacter = Character.Newline
extension Character {
  /// Represents a newline character.
  public struct Newline: _SpecificCharacter {
    public static func expects(_ character: Character) -> Bool {
      return character.isNewline
    }

    /// LF(U+000A)
    public static let lineFeed: Newline = "\u{000A}"

    /// CR(U+000D)
    public static let carriageReturn: Newline = "\u{000D}"

    /// CR+LF
    public static let carriageReturnAndLineFeed: Newline = "\u{000D}\u{000A}"

    public fileprivate(set) var rawValue: Character

    init(validatedCharacter: Character) {
      assert(Newline.expects(validatedCharacter))
      self.rawValue = validatedCharacter
    }
  }
}
