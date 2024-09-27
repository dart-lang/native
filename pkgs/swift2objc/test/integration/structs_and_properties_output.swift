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
  
  @objc public var customGetterProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customGetterProperty)
    }
  }
  
  @objc public var customSetterProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customSetterProperty)
    }
    set {
      wrappedInstance.customSetterProperty = newValue.wrappedInstance
    }
  }
  
  @objc public var customConstantProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customConstantProperty)
    }
  }
  
  @objc public var customVariableProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customVariableProperty)
    }
    set {
      wrappedInstance.customVariableProperty = newValue.wrappedInstance
    }
  }
  
  @objc public var implicitGetterProperty: Int {
    get {
      wrappedInstance.implicitGetterProperty
    }
  }
  
  @objc public var representableGetterProperty: Int {
    get {
      wrappedInstance.representableGetterProperty
    }
  }
  
  @objc public var representableSetterProperty: Int {
    get {
      wrappedInstance.representableSetterProperty
    }
    set {
      wrappedInstance.representableSetterProperty = newValue
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
  
  init(_ wrappedInstance: MyStruct) {
    self.wrappedInstance = wrappedInstance
  }
}
