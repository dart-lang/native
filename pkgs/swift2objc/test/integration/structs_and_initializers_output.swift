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
}
