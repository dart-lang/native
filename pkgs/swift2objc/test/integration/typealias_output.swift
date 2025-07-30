// Test preamble text

import Foundation

public typealias Bar = MyClass;
public typealias Foo = Int;
@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func method(x: MyClassWrapper.Baz) -> Foo {
    return wrappedInstance.method(x: x)
  }

  public typealias Baz = Bar;
}

