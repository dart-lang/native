import Foundation

public class MyClass {
  public init(y: Int) throws {}

  public func voidMethod() throws {}
  public func intMethod(y: Int) throws -> MyClass { return try MyClass(y: 123) }
}

public func voidFunc(x: Int, y: Int) throws {}
public func intFunc() throws -> MyClass { return try MyClass(y: 123) }
