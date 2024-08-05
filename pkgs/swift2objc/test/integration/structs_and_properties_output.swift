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
  
  @objc var customGetterVariable: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customGetterVariable)
    }
  }
  
  @objc var customSetterVariable: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customSetterVariable)
    }
    set {
      wrappedInstance.customSetterVariable = newValue.wrappedInstance
    }
  }
  
  @objc var customConstantProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customConstantProperty)
    }
  }
  
  @objc var customVariableProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customVariableProperty)
    }
    set {
      wrappedInstance.customVariableProperty = newValue.wrappedInstance
    }
  }
  
  @objc var representableGetterVariable: Int {
    get {
      wrappedInstance.representableGetterVariable
    }
  }
  
  @objc var representableSetterVariable: Int {
    get {
      wrappedInstance.representableSetterVariable
    }
    set {
      wrappedInstance.representableSetterVariable = newValue
    }
  }
  
  @objc var representableConstantProperty: Int {
    get {
      wrappedInstance.representableConstantProperty
    }
  }
  
  @objc var representableVariableProperty: Int {
    get {
      wrappedInstance.representableVariableProperty
    }
    set {
      wrappedInstance.representableVariableProperty = newValue
    }
  }
  
  init(_ wrappedInstance: MyStruct) {
    self.wrappedInstance = wrappedInstance
  }
}
