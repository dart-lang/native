// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func intFuncWrapper() throws -> MyClassWrapper {
    let result = try intFunc()
    return MyClassWrapper(result)
  }

  @objc static public func voidFuncWrapper(x: Int, y: Int) throws {
    return try voidFunc(x: x, y: y)
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(y: Int) throws {
    wrappedInstance = try MyClass(y: y)
  }

  @objc public func voidMethod() throws {
    return try wrappedInstance.voidMethod()
  }

  @objc public func intMethod(y: Int) throws -> MyClassWrapper {
    let result = try wrappedInstance.intMethod(y: y)
    return MyClassWrapper(result)
  }

}

