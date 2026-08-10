import Foundation

@objc public protocol MySwiftProtocol: NSObjectProtocol {
  @objc func getValue() -> Int
}

@objc public class MySwiftClass: NSObject, MySwiftProtocol {
  var val = 123;
  @objc public func getValue() -> Int {
    return val;
  }
  @objc public func setValue(x: Int) {
    val = x;
  }
}
