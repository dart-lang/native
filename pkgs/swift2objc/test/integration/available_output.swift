// Test preamble text

import Foundation

@available(macOS, introduced: 123.0.0)
@available(iOS, introduced: 100)
@objc public class NewApiWrapper: NSObject {
  var wrappedInstance: NewApi

  init(_ wrappedInstance: NewApi) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 123.0.0)
  @available(iOS, introduced: 100)
  @objc public func method1() -> Int {
    return wrappedInstance.method1()
  }

  @available(macOS, introduced: 123.4.5)
  @available(iOS, introduced: 100.0)
  @objc public func method2() -> Int {
    return wrappedInstance.method2()
  }

  @available(macOS, introduced: 200, deprecated: 201, obsoleted: 202)
  @available(iOS, unavailable, introduced: 100)
  @objc public func method3() -> Int {
    return wrappedInstance.method3()
  }

}

