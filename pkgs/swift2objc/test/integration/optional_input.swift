import Foundation

public func funcOptionalClassReturn() -> MyClass? { return MyClass(label: nil) }
public func funcOptionalStructReturn() -> MyStruct? { return nil }
public func funcOptionalArgs(label param: MyClass?) -> MyClass { return param! }
public func funcMultipleOptionalArgs(
    label1 param1: MyClass?,label2 param2: Int, label3 param3: MyStruct?){}
public func funcOptionalStrings(str: String?) -> String? { return str; }

public var globalOptional: MyStruct?

public class MyClass {
  public var optionalProperty: MyClass?

  public init(label param: MyClass?) {
    self.optionalProperty = param
  }

  public init(label1 param1: MyClass?, label2: Int, label3 param3: MyStruct?) {
    self.optionalProperty = param1
  }

  public func methodOptionalReturn() -> MyClass? { return nil }
  public func methodOptionalArgs(label param: MyClass?) {}
}

public struct MyStruct {
  public var optionalProperty: MyClass?

  public init(label param: MyClass?) {
    self.optionalProperty = param
  }

  public func methodOptionalReturn() -> MyStruct? { return nil }
  public func methodOptionalArgs(label param: MyClass?) {}
}
