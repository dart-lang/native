// Test preamble text

import Foundation

@objc public class MyOtherClassWrapper: NSObject {
  var wrappedInstance: MyOtherClass
  
  init(_ wrappedInstance: MyOtherClass) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass
  
  @objc public var customGetterVariable: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.customGetterVariable)
    }
  }
  
  @objc public var customSetterVariable: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.customSetterVariable)
    }
    set {
      wrappedInstance.customSetterVariable = newValue.wrappedInstance
    }
  }
  
  @objc public var customConstantProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.customConstantProperty)
    }
  }
  
  @objc public var customVariableProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.customVariableProperty)
    }
    set {
      wrappedInstance.customVariableProperty = newValue.wrappedInstance
    }
  }
  
  @objc public var representableGetterVariable: Int {
    get {
      wrappedInstance.representableGetterVariable
    }
  }
  
  @objc public var representableSetterVariable: Int {
    get {
      wrappedInstance.representableSetterVariable
    }
    set {
      wrappedInstance.representableSetterVariable = newValue
    }
  }
  
  @objc public var representableConstantProperty: Int {
    get {
      wrappedInstance.representableConstantProperty
    }
  }
  
  @objc public var representableVariableProperty: Int {
    get {
      wrappedInstance.representableVariableProperty
    }
    set {
      wrappedInstance.representableVariableProperty = newValue
    }
  }
  
  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }
}
