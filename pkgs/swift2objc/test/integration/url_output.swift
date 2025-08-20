// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func urlFuncWrapper(url: NSURL) -> NSURL {
    return urlFunc(url: url)
  }

}

