// Test preamble text

import Foundation

@objc public class OuterClassWrapper: NSObject {
  var wrappedInstance: OuterClass

  init(_ wrappedInstance: OuterClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc static public func makeOuter() -> OuterClassWrapper {
    let result = OuterClass.makeOuter()
    return OuterClassWrapper(result)
  }

  @objc static public func makeInnerClass() -> OuterClassWrapper.InnerClassWrapper {
    let result = OuterClass.makeInnerClass()
    return InnerClassWrapper(result)
  }

  @objc static public func makeInnerStruct() -> OuterClassWrapper.InnerStructWrapper {
    let result = OuterClass.makeInnerStruct()
    return InnerStructWrapper(result)
  }

  @objc public class InnerClassWrapper: NSObject {
    var wrappedInstance: OuterClass.InnerClass

    init(_ wrappedInstance: OuterClass.InnerClass) {
      self.wrappedInstance = wrappedInstance
    }

    @objc static public func makeOuter() -> OuterClassWrapper {
      let result = OuterClass.InnerClass.makeOuter()
      return OuterClassWrapper(result)
    }

    @objc static public func makeInner() -> OuterClassWrapper.InnerClassWrapper {
      let result = OuterClass.InnerClass.makeInner()
      return InnerClassWrapper(result)
    }

  }

  @objc public class InnerStructWrapper: NSObject {
    var wrappedInstance: OuterClass.InnerStruct

    init(_ wrappedInstance: OuterClass.InnerStruct) {
      self.wrappedInstance = wrappedInstance
    }

    @objc static public func makeOuter() -> OuterClassWrapper {
      let result = OuterClass.InnerStruct.makeOuter()
      return OuterClassWrapper(result)
    }

    @objc static public func makeInner() -> OuterClassWrapper.InnerStructWrapper {
      let result = OuterClass.InnerStruct.makeInner()
      return InnerStructWrapper(result)
    }

  }

}

@objc public class OuterStructWrapper: NSObject {
  var wrappedInstance: OuterStruct

  init(_ wrappedInstance: OuterStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc static public func makeOuter() -> OuterStructWrapper {
    let result = OuterStruct.makeOuter()
    return OuterStructWrapper(result)
  }

  @objc static public func makeInnerStruct() -> OuterStructWrapper.InnerStructWrapper {
    let result = OuterStruct.makeInnerStruct()
    return InnerStructWrapper(result)
  }

  @objc static public func makeInnerClass() -> OuterStructWrapper.InnerClassWrapper {
    let result = OuterStruct.makeInnerClass()
    return InnerClassWrapper(result)
  }

  @objc public class InnerStructWrapper: NSObject {
    var wrappedInstance: OuterStruct.InnerStruct

    init(_ wrappedInstance: OuterStruct.InnerStruct) {
      self.wrappedInstance = wrappedInstance
    }

    @objc static public func makeOuter() -> OuterStructWrapper {
      let result = OuterStruct.InnerStruct.makeOuter()
      return OuterStructWrapper(result)
    }

    @objc static public func makeInner() -> OuterStructWrapper.InnerStructWrapper {
      let result = OuterStruct.InnerStruct.makeInner()
      return InnerStructWrapper(result)
    }

  }

  @objc public class InnerClassWrapper: NSObject {
    var wrappedInstance: OuterStruct.InnerClass

    init(_ wrappedInstance: OuterStruct.InnerClass) {
      self.wrappedInstance = wrappedInstance
    }

    @objc static public func makeOuter() -> OuterStructWrapper {
      let result = OuterStruct.InnerClass.makeOuter()
      return OuterStructWrapper(result)
    }

    @objc static public func makeInner() -> OuterStructWrapper.InnerClassWrapper {
      let result = OuterStruct.InnerClass.makeInner()
      return InnerClassWrapper(result)
    }

  }

}

