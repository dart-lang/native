// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func globalClassGetterWrapper() async -> MyClassWrapper {
    let result = await globalClassGetter
    return MyClassWrapper(result)
  }

  @objc static public func globalOtherClassGetterWrapper() async throws -> OtherClassWrapper {
    let result = try await globalOtherClassGetter
    return OtherClassWrapper(result)
  }

}

@objc public class OtherClassWrapper: NSObject {
  var wrappedInstance: OtherClass

  init(_ wrappedInstance: OtherClass) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func otherClassGetter() async throws -> OtherClassWrapper {
    let result = try await wrappedInstance.otherClassGetter
    return OtherClassWrapper(result)
  }

  @objc public func classGetter() async -> MyClassWrapper {
    let result = await wrappedInstance.classGetter
    return MyClassWrapper(result)
  }

  @objc static public func initWrapper(y: Int) async -> MyClassWrapper {
    let instance = await MyClass(y: y)
    return MyClassWrapper(instance)
  }

}

