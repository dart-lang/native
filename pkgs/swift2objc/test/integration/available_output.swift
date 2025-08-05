// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @available(macOS, obsoleted: 999)
  @available(iOS, introduced: 1234.5.6)
  @objc static public var globalVarWrapper: Int {
    get {
      globalVar
    }
    set {
      globalVar = newValue
    }
  }

  @available(macOS, introduced: 234.5.6)
  @available(iOS, unavailable)
  @objc static public func globalFuncWrapper(x: NewApiWrapper) -> Int {
    return globalFunc(x: x.wrappedInstance)
  }

}

@available(macOS, introduced: 123.0.0)
@available(iOS, introduced: 100)
@objc public class NewApiWrapper: NSObject {
  var wrappedInstance: NewApi

  @available(macOS, introduced: 123.0.0)
  @available(iOS, introduced: 100)
  @objc public var prop1: Int {
    get {
      wrappedInstance.prop1
    }
    set {
      wrappedInstance.prop1 = newValue
    }
  }

  @available(macOS, introduced: 123.0.0, deprecated: 345.6)
  @available(iOS, introduced: 234.5.6)
  @objc public var prop2: Int {
    get {
      wrappedInstance.prop2
    }
    set {
      wrappedInstance.prop2 = newValue
    }
  }

  init(_ wrappedInstance: NewApi) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 456)
  @available(iOS, introduced: 101)
  @objc init(x: Int) {
    wrappedInstance = NewApi(x: x)
  }

  @available(macOS, introduced: 123.0.0)
  @available(iOS, introduced: 100)
  @objc public func method1() -> Int {
    return wrappedInstance.method1()
  }

  @available(macOS, introduced: 123.4.5)
  @available(iOS, introduced: 100.1)
  @objc public func method2() -> Int {
    return wrappedInstance.method2()
  }

  @available(macOS, introduced: 200, deprecated: 201, obsoleted: 202)
  @available(iOS, unavailable, introduced: 100)
  @objc public func method3() -> Int {
    return wrappedInstance.method3()
  }

}

@available(macOS, introduced: 123.0.0)
@available(iOS, introduced: 100)
@objc public class NewStructWrapper: NSObject {
  var wrappedInstance: NewStruct

  @available(macOS, introduced: 123.0.0)
  @available(iOS, introduced: 100)
  @objc public var prop1: Int {
    get {
      wrappedInstance.prop1
    }
    set {
      wrappedInstance.prop1 = newValue
    }
  }

  @available(macOS, introduced: 123.0.0, deprecated: 345.6)
  @available(iOS, introduced: 234.5.6)
  @objc public var prop2: Int {
    get {
      wrappedInstance.prop2
    }
    set {
      wrappedInstance.prop2 = newValue
    }
  }

  init(_ wrappedInstance: NewStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 123.0.0)
  @available(iOS, introduced: 100)
  @objc public func method1() -> Int {
    return wrappedInstance.method1()
  }

  @available(macOS, introduced: 123.4.5)
  @available(iOS, introduced: 100.1)
  @objc public func method2() -> Int {
    return wrappedInstance.method2()
  }

}

