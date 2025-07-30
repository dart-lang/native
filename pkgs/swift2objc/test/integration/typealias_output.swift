// Test preamble text

import Foundation

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func method(x: Baz) -> Foo {
    return wrappedInstance.method(x: x)
  }

}

