// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func intFuncWrapper() async -> MyClassWrapper {
    let result = await intFunc()
    return MyClassWrapper(result)
  }

  @objc static public func voidFuncWrapper(x: Int, y: Int) async {
    return await voidFunc(x: x, y: y)
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func voidMethod() async {
    return await wrappedInstance.voidMethod()
  }

  @objc public func asyncThrowsMethod(y: Int) async throws -> MyClassWrapper {
    let result = try await wrappedInstance.asyncThrowsMethod(y: y)
    return MyClassWrapper(result)
  }

  @objc public func intMethod(y: Int) async -> MyClassWrapper {
    let result = await wrappedInstance.intMethod(y: y)
    return MyClassWrapper(result)
  }

}

