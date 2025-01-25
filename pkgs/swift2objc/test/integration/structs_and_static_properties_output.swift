// Test preamble text

import Foundation

@objc public class MyOtherStructWrapper: NSObject {
  var wrappedInstance: MyOtherStruct

  init(_ wrappedInstance: MyOtherStruct) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class MyStructWrapper: NSObject {
  var wrappedInstance: MyStruct

  @objc static public var customGetterVariable: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(MyStruct.customGetterVariable)
    }
  }

  @objc static public var customSetterVariable: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(MyStruct.customSetterVariable)
    }
    set {
      MyStruct.customSetterVariable = newValue.wrappedInstance
    }
  }

  @objc static public var customConstantProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(MyStruct.customConstantProperty)
    }
  }

  @objc static public var customVariableProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(MyStruct.customVariableProperty)
    }
    set {
      MyStruct.customVariableProperty = newValue.wrappedInstance
    }
  }

  @objc static public var representableGetterVariable: Int {
    get {
      MyStruct.representableGetterVariable
    }
  }

  @objc static public var representableSetterVariable: Int {
    get {
      MyStruct.representableSetterVariable
    }
    set {
      MyStruct.representableSetterVariable = newValue
    }
  }

  @objc static public var representableConstantProperty: Int {
    get {
      MyStruct.representableConstantProperty
    }
  }

  @objc static public var representableVariableProperty: Int {
    get {
      MyStruct.representableVariableProperty
    }
    set {
      MyStruct.representableVariableProperty = newValue
    }
  }

  init(_ wrappedInstance: MyStruct) {
    self.wrappedInstance = wrappedInstance
  }

}

