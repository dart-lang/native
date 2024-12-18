// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public var globalOptionalWrapper: MyStructWrapper? {
    get {
      globalOptional == nil ? nil : MyStructWrapper(globalOptional!)
    }
    set {
      globalOptional = newValue?.wrappedInstance
    }
  }

  @objc static public func funcOptionalArgsWrapper(label param: MyClassWrapper?) -> MyClassWrapper {
    let result = funcOptionalArgs(label: param?.wrappedInstance)
    return MyClassWrapper(result)
  }

  @objc static public func funcOptionalStringsWrapper(str: String?) -> String? {
    return funcOptionalStrings(str: str)
  }

  @objc static public func funcOptionalClassReturnWrapper() -> MyClassWrapper? {
    let result = funcOptionalClassReturn()
    return result == nil ? nil : MyClassWrapper(result!)
  }

  @objc static public func funcMultipleOptionalArgsWrapper(label1 param1: MyClassWrapper?, label2 param2: Int, label3 param3: MyStructWrapper?) {
    return funcMultipleOptionalArgs(label1: param1?.wrappedInstance, label2: param2, label3: param3?.wrappedInstance)
  }

  @objc static public func funcOptionalStructReturnWrapper() -> MyStructWrapper? {
    let result = funcOptionalStructReturn()
    return result == nil ? nil : MyStructWrapper(result!)
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  @objc public var optionalProperty: MyClassWrapper? {
    get {
      wrappedInstance.optionalProperty == nil ? nil : MyClassWrapper(wrappedInstance.optionalProperty!)
    }
    set {
      wrappedInstance.optionalProperty = newValue?.wrappedInstance
    }
  }

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(label param: MyClassWrapper?) {
    wrappedInstance = MyClass(label: param?.wrappedInstance)
  }

  @objc init(label1 param1: MyClassWrapper?, label2: Int, label3 param3: MyStructWrapper?) {
    wrappedInstance = MyClass(label1: param1?.wrappedInstance, label2: label2, label3: param3?.wrappedInstance)
  }

  @objc public func methodOptionalArgs(label param: MyClassWrapper?) {
    return wrappedInstance.methodOptionalArgs(label: param?.wrappedInstance)
  }

  @objc public func methodOptionalReturn() -> MyClassWrapper? {
    let result = wrappedInstance.methodOptionalReturn()
    return result == nil ? nil : MyClassWrapper(result!)
  }

}

@objc public class MyStructWrapper: NSObject {
  var wrappedInstance: MyStruct

  @objc public var optionalProperty: MyClassWrapper? {
    get {
      wrappedInstance.optionalProperty == nil ? nil : MyClassWrapper(wrappedInstance.optionalProperty!)
    }
    set {
      wrappedInstance.optionalProperty = newValue?.wrappedInstance
    }
  }

  init(_ wrappedInstance: MyStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(label param: MyClassWrapper?) {
    wrappedInstance = MyStruct(label: param?.wrappedInstance)
  }

  @objc public func methodOptionalArgs(label param: MyClassWrapper?) {
    return wrappedInstance.methodOptionalArgs(label: param?.wrappedInstance)
  }

  @objc public func methodOptionalReturn() -> MyStructWrapper? {
    let result = wrappedInstance.methodOptionalReturn()
    return result == nil ? nil : MyStructWrapper(result!)
  }

}

