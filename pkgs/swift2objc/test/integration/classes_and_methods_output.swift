// Test preamble text

import Foundation

@objc public class MyOtherClassWrapper: NSObject {
  var wrappedInstance: MyOtherClass

  init(_ wrappedInstance: MyOtherClass) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func myMethod(label1 param1: Int, param2: MyOtherClassWrapper) -> MyOtherClassWrapper {
    let result = wrappedInstance.myMethod(label1: param1, param2: param2.wrappedInstance)
    return MyOtherClassWrapper(result)
  }

  @objc public func myMethod2() {
    return wrappedInstance.myMethod2()
  }

  @objc public func myMethod3() {
    return wrappedInstance.myMethod3()
  }

}

