// Test preamble text

import Foundation

@objc public class CustomIndexWrapper: NSObject {
  var wrappedInstance: CustomIndex

  init(_ wrappedInstance: CustomIndex) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class ClassWithSubscriptsWrapper: NSObject {
  var wrappedInstance: ClassWithSubscripts

  init(_ wrappedInstance: ClassWithSubscripts) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getValue(_ x: Int, _ y: Int) -> String {
    return wrappedInstance[x, y]
  }

  @objc public func setValue(_ x: Int, _ y: Int, newValue: String) {
    wrappedInstance[x, y] = newValue
  }

  @objc public func getValue() -> String {
    return wrappedInstance[]
  }

  @objc public func setValue(newValue: String) {
    wrappedInstance[] = newValue
  }

  @objc static public func getValue(_ index: Int) -> String {
    return ClassWithSubscripts[index]
  }

  @objc static public func setValue(_ index: Int, newValue: String) {
    ClassWithSubscripts[index] = newValue
  }

  @objc public func getValue(_ index: CustomIndexWrapper) -> String {
    return wrappedInstance[index.wrappedInstance]
  }

  @objc public func setValue(_ index: CustomIndexWrapper, newValue: String) {
    wrappedInstance[index.wrappedInstance] = newValue
  }

  @objc public func getValue(_ index: Int?) -> String {
    return wrappedInstance[index]
  }

  @objc public func setValue(_ index: Int?, newValue: String) {
    wrappedInstance[index] = newValue
  }

  @objc public func getValue(throwing index: Int) throws -> String {
    return try wrappedInstance[throwing: index]
  }

  @objc public func getValue(async index: Int) async -> String {
    return await wrappedInstance[async: index]
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

}

@objc public class StructWithSubscriptWrapper: NSObject {
  var wrappedInstance: StructWithSubscript

  init(_ wrappedInstance: StructWithSubscript) {
    self.wrappedInstance = wrappedInstance
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

}

