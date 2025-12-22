import Foundation

@objc public class TestEmptyClass: NSObject {}

@objc public class TestFuncs: NSObject {
  @objc public static func echoObject() -> NSObject? {
    return TestEmptyClass()
  }
}
