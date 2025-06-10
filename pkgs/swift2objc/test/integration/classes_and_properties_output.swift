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

  @objc public var lazyProperty: Int {
    get {
      wrappedInstance.lazyProperty
    }
    set {
      wrappedInstance.lazyProperty = newValue
    }
  }

  @objc public weak var weakProperty: MyOtherClassWrapper? {
    get {
      wrappedInstance.weakProperty == nil ? nil : MyOtherClassWrapper(wrappedInstance.weakProperty!)
    }
    set {
      wrappedInstance.weakProperty = newValue?.wrappedInstance
    }
  }

  @objc public unowned var unownedProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.unownedProperty)
    }
    set {
      wrappedInstance.unownedProperty = newValue.wrappedInstance
    }
  }

  @objc public var customGetterProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.customGetterProperty)
    }
  }

  @objc public var customSetterProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.customSetterProperty)
    }
    set {
      wrappedInstance.customSetterProperty = newValue.wrappedInstance
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

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

}

