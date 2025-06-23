// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func globalClassGetterWrapper() throws -> MyClassWrapper {
    let result = try globalClassGetter
    return MyClassWrapper(result)
  }

  @objc static public func globalOtherClassGetterWrapper() throws -> OtherClassWrapper {
    let result = try globalOtherClassGetter
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

  @objc init(y: Int) throws {
    wrappedInstance = try MyClass(y: y)
  }

  @objc public func otherClassGetter() throws -> OtherClassWrapper {
    let result = try wrappedInstance.otherClassGetter
    return OtherClassWrapper(result)
  }

  @objc public func classGetter() throws -> MyClassWrapper {
    let result = try wrappedInstance.classGetter
    return MyClassWrapper(result)
  }

}

