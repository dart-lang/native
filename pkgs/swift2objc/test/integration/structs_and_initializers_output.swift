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

  @objc public var customProperty: MyOtherStructWrapper {
    get {
      MyOtherStructWrapper(wrappedInstance.customProperty)
    }
  }

  @objc public var representableProperty: Int {
    get {
      wrappedInstance.representableProperty
    }
  }

  init(_ wrappedInstance: MyStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(outerLabel representableProperty: Int, customProperty: MyOtherStructWrapper) {
    wrappedInstance = MyStruct(outerLabel: representableProperty, customProperty: customProperty.wrappedInstance)
  }

  @objc init?(outerLabel x: Int) {
    if let instance = MyStruct(outerLabel: x) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init(label1 name1: Int, label2: Int, _ name3: Int) {
    wrappedInstance = MyStruct(label1: name1, label2: label2, name3)
  }

}

