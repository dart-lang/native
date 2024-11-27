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

  @objc public var customProperty: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(wrappedInstance.customProperty)
    }
  }

  @objc public var representableProperty: Int {
    get {
      wrappedInstance.representableProperty
    }
  }

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(outerLabel representableProperty: Int, customProperty: MyOtherClassWrapper) {
    wrappedInstance = MyClass(outerLabel: representableProperty, customProperty: customProperty.wrappedInstance)
  }

  @objc init?(outerLabel x: Int) {
    if let instance = MyClass(outerLabel: x) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init(label1 name1: Int, label2: Int, _ name3: Int) {
    wrappedInstance = MyClass(label1: name1, label2: label2, name3)
  }

}

