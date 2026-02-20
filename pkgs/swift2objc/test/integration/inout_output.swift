// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func swapTwoIntsWrapper(_ a: IntWrapper, _ b: IntWrapper) {
    return swapTwoInts(&a.wrappedInstance, &b.wrappedInstance)
  }

  @objc static public func replaceOtherWrapper(_ value: MyOtherClassWrapper) {
    return replaceOther(&value.wrappedInstance)
  }

}

@objc public class MyOtherClassWrapper: NSObject {
  var wrappedInstance: MyOtherClass

  init(_ wrappedInstance: MyOtherClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override public init() {
    wrappedInstance = MyOtherClass()
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func update(_ value: IntWrapper) {
    return wrappedInstance.update(&value.wrappedInstance)
  }

}

@objc public class IntWrapper: NSObject {
  var wrappedInstance: Int

  init(_ wrappedInstance: Int) {
    self.wrappedInstance = wrappedInstance
  }

}

