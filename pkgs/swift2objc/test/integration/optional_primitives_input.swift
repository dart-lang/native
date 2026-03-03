import Foundation
public class MyClass {
  public func optionalIntReturn() -> Int? { return nil }
  public func optionalFloatReturn() -> Float? { return nil }
  public func optionalDoubleReturn() -> Double? { return nil }
  public func optionalBoolReturn() -> Bool? { return nil }
  public func optionalIntArg(label param: Int?) {}
  public func optionalBoolArg(label param: Bool?) {}
  public var optionalIntProperty: Int?
}
public func globalOptionalIntReturn() -> Int? { return nil }
public func globalOptionalIntArg(label param: Int?) {}