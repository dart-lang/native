// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func greetWrapper(name: String) -> String {
    return greet(name: name)
  }

}

