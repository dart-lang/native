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
  
  @objc static public func myMethod(label1 param1: Int, param2: MyOtherStructWrapper) -> MyOtherStructWrapper {
    let result = MyStruct.myMethod(label1: param1, param2: param2.wrappedInstance)
    return MyOtherStructWrapper(result)
  }
  
  @objc static public func myMethod2() -> Void {
    return MyStruct.myMethod2()
  }
  
  @objc static public func myMethod3() {
    MyStruct.myMethod3()
  }
}
