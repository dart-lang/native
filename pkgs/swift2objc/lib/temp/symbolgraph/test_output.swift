import Foundation

@objc public class MyClass1Wrapper: NSObject {
  var wrappedInstance: MyClass1
  
  init(_ wrappedInstance: MyClass1) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class MyClass2Wrapper: NSObject {
  var wrappedInstance: MyClass2
  
  init(_ wrappedInstance: MyClass2) {
    self.wrappedInstance = wrappedInstance
  }
}
