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
  
  @objc func myMethod(label1 param1: Int, param2: MyOtherStructWrapper) -> MyOtherStructWrapper {
    let result = wrappedInstance.myMethod(label1: param1, param2: param2.wrappedInstance)
    return MyOtherStructWrapper(result)
  }
  
  @objc func myMethod2() -> Void {
    return wrappedInstance.myMethod2()
  }
  
  @objc func myMethod3() {
    wrappedInstance.myMethod3()
  }
}
