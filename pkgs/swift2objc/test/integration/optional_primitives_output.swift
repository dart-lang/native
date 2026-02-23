// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func globalOptionalIntArgWrapper(label param: IntWrapper?) {
    return globalOptionalIntArg(label: param?.wrappedInstance)
  }

  @objc static public func globalOptionalIntReturnWrapper() -> IntWrapper? {
    let result = globalOptionalIntReturn()
    return result == nil ? nil : IntWrapper(result!)
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  @objc public var optionalIntProperty: IntWrapper? {
    get {
      wrappedInstance.optionalIntProperty == nil ? nil : IntWrapper(wrappedInstance.optionalIntProperty!)
    }
    set {
      wrappedInstance.optionalIntProperty = newValue?.wrappedInstance
    }
  }

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func optionalBoolReturn() -> BoolWrapper? {
    let result = wrappedInstance.optionalBoolReturn()
    return result == nil ? nil : BoolWrapper(result!)
  }

  @objc public func optionalFloatReturn() -> FloatWrapper? {
    let result = wrappedInstance.optionalFloatReturn()
    return result == nil ? nil : FloatWrapper(result!)
  }

  @objc public func optionalDoubleReturn() -> DoubleWrapper? {
    let result = wrappedInstance.optionalDoubleReturn()
    return result == nil ? nil : DoubleWrapper(result!)
  }

  @objc public func optionalIntArg(label param: IntWrapper?) {
    return wrappedInstance.optionalIntArg(label: param?.wrappedInstance)
  }

  @objc public func optionalBoolArg(label param: BoolWrapper?) {
    return wrappedInstance.optionalBoolArg(label: param?.wrappedInstance)
  }

  @objc public func optionalIntReturn() -> IntWrapper? {
    let result = wrappedInstance.optionalIntReturn()
    return result == nil ? nil : IntWrapper(result!)
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

