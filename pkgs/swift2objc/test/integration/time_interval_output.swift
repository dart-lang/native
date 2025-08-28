// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func timeIntervalFuncWrapper(t: TimeInterval) -> TimeInterval {
    return timeIntervalFunc(t: t)
  }

}

