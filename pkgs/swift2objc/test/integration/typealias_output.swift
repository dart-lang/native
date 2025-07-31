// Test preamble text

import Foundation

public typealias BarBarWrapper = BarWrapper;
public typealias BarNullableWrapper = BarWrapper?;
public typealias BarWrapper = MyClassWrapper;
@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func method1(x: Foo) -> Foo {
    return wrappedInstance.method1(x: x)
  }

  @objc public func method2(x: BarWrapper) -> MyClassWrapper {
    let result = wrappedInstance.method2(x: x.wrappedInstance)
    return MyClassWrapper(result)
  }

  @objc public func method3(x: BarNullableWrapper) -> MyClassWrapper? {
    let result = wrappedInstance.method3(x: x?.wrappedInstance)
    return result == nil ? nil : MyClassWrapper(result!)
  }

  @objc public func method4(x: MyClassWrapper.BazWrapper) -> MyClassWrapper {
    let result = wrappedInstance.method4(x: x.wrappedInstance)
    return MyClassWrapper(result)
  }

  public typealias BazWrapper = BarWrapper;
}

