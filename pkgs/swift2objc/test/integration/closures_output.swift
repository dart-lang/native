// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func applyGlobalWrapper(callback: (Int) -> Int, value: Int) -> Int {
    return applyGlobal(callback: callback, value: value)
  }

  @objc static public func makeGlobalCallbackWrapper() -> (Int) -> Int {
    return makeGlobalCallback()
  }

}

@objc public class ClosureBoxWrapper: NSObject {
  var wrappedInstance: ClosureBox

  init(_ wrappedInstance: ClosureBox) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override public init() {
    wrappedInstance = ClosureBox()
  }

  @objc public func makeCallback() -> (Int) -> Int {
    return wrappedInstance.makeCallback()
  }

  @objc public func apply(callback: (Int) -> Int, value: Int) -> Int {
    return wrappedInstance.apply(callback: callback, value: value)
  }

}

