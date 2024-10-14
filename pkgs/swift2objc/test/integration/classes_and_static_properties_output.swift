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
  
  @objc static public var customGetterVariable: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(MyClass.customGetterVariable)
    }
  }
  
  @objc static public var customSetterVariable: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(MyClass.customSetterVariable)
    }
    set {
      MyClass.customSetterVariable = newValue.wrappedInstance
    }
  }
  
  @objc static public var customConstantProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(MyClass.customConstantProperty)
    }
  }
  
  @objc static public var customVariableProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(MyClass.customVariableProperty)
    }
    set {
      MyClass.customVariableProperty = newValue.wrappedInstance
    }
  }
  
  @objc static public var representableGetterVariable: Int {
    get {
      MyClass.representableGetterVariable
    }
  }
  
  @objc static public var representableSetterVariable: Int {
    get {
      MyClass.representableSetterVariable
    }
    set {
      MyClass.representableSetterVariable = newValue
    }
  }
  
  @objc static public var representableConstantProperty: Int {
    get {
      MyClass.representableConstantProperty
    }
  }
  
  @objc static public var representableVariableProperty: Int {
    get {
      MyClass.representableVariableProperty
    }
    set {
      MyClass.representableVariableProperty = newValue
    }
  }
  
  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }
}
