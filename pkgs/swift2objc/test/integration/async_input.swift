import Foundation

public class MyClass {
  public func voidMethod() async {}
  public func intMethod(y: Int) async -> MyClass { return MyClass() }
  public func asyncThrowsMethod(y: Int) async throws -> MyClass {
    return MyClass()
  }
}

public func voidFunc(x: Int, y: Int) async {}
public func intFunc() async -> MyClass { return MyClass() }
