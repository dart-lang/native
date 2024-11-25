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
  
  @objc public func myMethod(label1 param1: Int, param2: MyOtherStructWrapper) -> MyOtherStructWrapper {
    let result = wrappedInstance.myMethod(label1: param1, param2: param2.wrappedInstance)
    return MyOtherStructWrapper(result)
  }
  
  @objc public func myMethod2() {
    return wrappedInstance.myMethod2()
  }
  
  @objc public func myMethod3() {
    return wrappedInstance.myMethod3()
  }
}
