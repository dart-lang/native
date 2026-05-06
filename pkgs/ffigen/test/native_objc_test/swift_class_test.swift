import Foundation

@_cdecl("ffigen_load_swift_test")
public func ffigen_load_swift_test() {}

@objc public class MySwiftClass: NSObject {
  var val = 123;
  @objc public func getValue() -> Int {
    return val;
  }
  @objc public func setValue(x: Int) {
    val = x;
  }
}
