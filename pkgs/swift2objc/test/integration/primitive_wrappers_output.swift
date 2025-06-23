// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func doubleFuncWrapper() throws -> DoubleWrapper {
    let result = try doubleFunc()
    return DoubleWrapper(result)
  }

  @objc static public func globalVar1Wrapper() throws -> IntWrapper {
    let result = try globalVar1
    return IntWrapper(result)
  }

  @objc static public func globalVar2Wrapper() throws -> FloatWrapper {
    let result = try globalVar2
    return FloatWrapper(result)
  }

  @objc static public func globalVar3Wrapper() throws -> DoubleWrapper {
    let result = try globalVar3
    return DoubleWrapper(result)
  }

  @objc static public func globalVar4Wrapper() throws -> BoolWrapper {
    let result = try globalVar4
    return BoolWrapper(result)
  }

  @objc static public func globalVar5Wrapper() throws -> String {
    let result = try globalVar5
    return result
  }

  @objc static public func intFuncWrapper() throws -> IntWrapper {
    let result = try intFunc()
    return IntWrapper(result)
  }

  @objc static public func strFuncWrapper() throws -> String {
    return try strFunc()
  }

  @objc static public func boolFuncWrapper() throws -> BoolWrapper {
    let result = try boolFunc()
    return BoolWrapper(result)
  }

  @objc static public func floatFuncWrapper() throws -> FloatWrapper {
    let result = try floatFunc()
    return FloatWrapper(result)
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func doubleFunc() throws -> DoubleWrapper {
    let result = try wrappedInstance.doubleFunc()
    return DoubleWrapper(result)
  }

  @objc public func age() throws -> IntWrapper {
    let result = try wrappedInstance.age
    return IntWrapper(result)
  }

  @objc public func str() throws -> String {
    let result = try wrappedInstance.str
    return result
  }

  @objc public func name() throws -> FloatWrapper {
    let result = try wrappedInstance.name
    return FloatWrapper(result)
  }

  @objc public func height() throws -> DoubleWrapper {
    let result = try wrappedInstance.height
    return DoubleWrapper(result)
  }

  @objc public func isTrue() throws -> BoolWrapper {
    let result = try wrappedInstance.isTrue
    return BoolWrapper(result)
  }

  @objc public func intFunc() throws -> IntWrapper {
    let result = try wrappedInstance.intFunc()
    return IntWrapper(result)
  }

  @objc public func strFunc() throws -> String {
    return try wrappedInstance.strFunc()
  }

  @objc public func boolFunc() throws -> BoolWrapper {
    let result = try wrappedInstance.boolFunc()
    return BoolWrapper(result)
  }

  @objc public func floatFunc() throws -> FloatWrapper {
    let result = try wrappedInstance.floatFunc()
    return FloatWrapper(result)
  }

}

@objc public class BoolWrapper: NSObject {
  var wrappedInstance: Bool

  init(_ wrappedInstance: Bool) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class DoubleWrapper: NSObject {
  var wrappedInstance: Double

  init(_ wrappedInstance: Double) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class FloatWrapper: NSObject {
  var wrappedInstance: Float

  init(_ wrappedInstance: Float) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class IntWrapper: NSObject {
  var wrappedInstance: Int

  init(_ wrappedInstance: Int) {
    self.wrappedInstance = wrappedInstance
  }

}

