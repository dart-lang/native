// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func globalFuncWrapper(param: Int) -> Int {
    return globalFunc(param: param)
  }

  @objc static public func globalFuncWrapper() -> Int {
    return globalFunc()
  }

  @objc static public func multiDefaultWrapper(a: Int, b: Int, c: String) -> String {
    return multiDefault(a: a, b: b, c: c)
  }

  @objc static public func multiDefaultWrapper(a: Int, b: Int) -> String {
    return multiDefault(a: a, b: b)
  }

  @objc static public func multiDefaultWrapper(a: Int) -> String {
    return multiDefault(a: a)
  }

}

@objc public class GreeterWrapper: NSObject {
  var wrappedInstance: Greeter

  init(_ wrappedInstance: Greeter) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(greeting: String) {
    wrappedInstance = Greeter(greeting: greeting)
  }

  @objc override public init() {
    wrappedInstance = Greeter()
  }

  @objc public func greet(name: String, times: Int) -> String {
    return wrappedInstance.greet(name: name, times: times)
  }

  @objc public func greet(name: String) -> String {
    return wrappedInstance.greet(name: name)
  }

  @objc public func greet() -> String {
    return wrappedInstance.greet()
  }

}

