import Foundation

public class TestClass {
  public func myMethod() -> TestOtherClass {
    return TestOtherClass()
  }

  static func create() -> TestClass {
    return TestClass()
  }
}

public class TestOtherClass {
  public func times10(x: Int) -> Int {
    return x * 10
  }
}
