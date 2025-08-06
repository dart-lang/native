import Foundation

@objc public class TestClass: NSObject {
  @objc public func myMethod() -> TestOtherClass {
    return TestOtherClass()
  }

  @objc public static func create() -> TestClass {
    return TestClass()
  }
}

@objc public class TestOtherClass: NSObject {
  @objc public func times10(x: Int) -> Int {
    return x * 10
  }
}
