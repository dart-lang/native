// Test preamble text

import Foundation

@objc public class AsyncSubscriptWrapper: NSObject {
  var wrappedInstance: AsyncSubscript

  init(_ wrappedInstance: AsyncSubscript) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getValue(_ index: Int) async -> String {
    let result = await wrappedInstance[index]
    return result
  }

}

@objc public class SubscriptClassWrapper: NSObject {
  var wrappedInstance: SubscriptClass

  @objc public var stored: String {
    get {
      wrappedInstance.stored
    }
    set {
      wrappedInstance.stored = newValue
    }
  }

  @objc public subscript(_ index: Int) -> String {
    get {
      let result = wrappedInstance[index]
      return result
    }
    set {
      wrappedInstance[index] = newValue
    }
  }

  init(_ wrappedInstance: SubscriptClass) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class StaticSubscriptWrapper: NSObject {
  var wrappedInstance: StaticSubscript

  init(_ wrappedInstance: StaticSubscript) {
    self.wrappedInstance = wrappedInstance
  }

  @objc static public func getValue(_ name: String) -> String {
    let result =  StaticSubscript[name]
    return result
  }

}

@objc public class SubscriptStructWrapper: NSObject {
  var wrappedInstance: SubscriptStruct

  @objc public var value: Int {
    get {
      wrappedInstance.value
    }
    set {
      wrappedInstance.value = newValue
    }
  }

  @objc public subscript(_ index: Int) -> Int {
    get {
      let result = wrappedInstance[index]
      return result
    }
    set {
      wrappedInstance[index] = newValue
    }
  }

  init(_ wrappedInstance: SubscriptStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(value: Int) {
    wrappedInstance = SubscriptStruct(value: value)
  }

}

@objc public class OptionalSubscriptWrapper: NSObject {
  var wrappedInstance: OptionalSubscript

  init(_ wrappedInstance: OptionalSubscript) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getValue(_ opt: IntWrapper?) -> String? {
    let result =  wrappedInstance[opt?.wrappedInstance]
    return result
  }

}

@objc public class ThrowingSubscriptWrapper: NSObject {
  var wrappedInstance: ThrowingSubscript

  init(_ wrappedInstance: ThrowingSubscript) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getValue(_ index: Int) throws -> String {
    let result = try wrappedInstance[index]
    return result
  }

}

@objc public class ZeroArgsSubscriptWrapper: NSObject {
  var wrappedInstance: ZeroArgsSubscript

  init(_ wrappedInstance: ZeroArgsSubscript) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getValue() -> Int {
    let result =  wrappedInstance[]
    return result
  }

}

@objc public class MultipleArgsSubscriptWrapper: NSObject {
  var wrappedInstance: MultipleArgsSubscript

  init(_ wrappedInstance: MultipleArgsSubscript) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getValue(_ row: Int, _ col: Int) -> Int {
    let result =  wrappedInstance[row, col]
    return result
  }

}

@objc public class NonTrivialArgsSubscriptWrapper: NSObject {
  var wrappedInstance: NonTrivialArgsSubscript

  init(_ wrappedInstance: NonTrivialArgsSubscript) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getValue(_ other: SubscriptClassWrapper) -> Int {
    let result =  wrappedInstance[other.wrappedInstance]
    return result
  }

}

@objc public class IntWrapper: NSObject {
  var wrappedInstance: Int

  init(_ wrappedInstance: Int) {
    self.wrappedInstance = wrappedInstance
  }

}

