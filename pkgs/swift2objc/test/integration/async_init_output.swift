// Test preamble text

import Foundation

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = MyClass()
  }

  @objc static public func initWrapper(arg: Int) async -> MyClassWrapper {
    let instance = await MyClass(arg: arg)
    return MyClassWrapper(instance)
  }

  @objc static public func initWrapper(arg1: Int, arg2: Int) async throws -> MyClassWrapper {
    let instance = try await MyClass(arg1: arg1, arg2: arg2)
    return MyClassWrapper(instance)
  }

  @objc static public func initWrapper(label1 name1: Int, _ name2: Int) async -> MyClassWrapper? {
    if let instance = await MyClass(label1: name1, name2) {
      return MyClassWrapper(instance)
    } else {
      return nil
    }
  }

}

