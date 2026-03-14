// Test preamble text

import Foundation

@objc public class MyEnumWrapper: NSObject {
  var wrappedInstance: MyEnum

  @objc static public var myCase: MyEnumWrapper {
    get {
      MyEnumWrapper(MyEnum.myCase)
    }
  }

  init(_ wrappedInstance: MyEnum) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func originalFunc() -> Int {
    return wrappedInstance.originalFunc()
  }

}

@objc public class MyStructWrapper: NSObject {
  var wrappedInstance: MyStruct

  init(_ wrappedInstance: MyStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func originalStructFunc() -> Int {
    return wrappedInstance.originalStructFunc()
  }

}

@objc public class BareClassWrapper: NSObject {
  var wrappedInstance: BareClass

  init(_ wrappedInstance: BareClass) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc extension MyEnumWrapper {
  @objc public func extensionEnumFunc() -> Int {
    return wrappedInstance.extensionEnumFunc()
  }

}

@objc extension MyClassWrapper {
  @objc public func extensionFunc(p: String) -> Int {
    return wrappedInstance.extensionFunc(p: p)
  }

  @objc static public func staticExtensionFunc() -> Int {
    return MyClass.staticExtensionFunc()
  }

  @objc public var extensionComputedProp: Int {
    get {
      wrappedInstance.extensionComputedProp
    }
  }

}

@objc extension MyStructWrapper {
  @objc public func extensionStructFunc(p: String) -> Int {
    return wrappedInstance.extensionStructFunc(p: p)
  }

  @objc static public func extensionStaticFunc() -> Int {
    return MyStruct.extensionStaticFunc()
  }

  @objc public init(value: Int) {
    wrappedInstance = MyStruct(value: value)
  }

}

@objc extension BareClassWrapper {
  @objc public func fromExtension() -> Int {
    return wrappedInstance.fromExtension()
  }

}

