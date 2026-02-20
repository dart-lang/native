import Foundation

public class MyClass {
  public func update(_ value: inout Int) {
    value += 1
  }
}

public class MyOtherClass {
  public init() {}
}

public func swapTwoInts(_ a: inout Int, _ b: inout Int) {
  let temp = a
  a = b
  b = temp
}

public func replaceOther(_ value: inout MyOtherClass) {
  value = MyOtherClass()
}
