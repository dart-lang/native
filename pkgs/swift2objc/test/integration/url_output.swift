// Test preamble text

import Foundation

// This wrapper is a stub. To generate the full wrapper, add NSURL
// to your config's include function.
@objc public class NSURLWrapper: NSObject {
  var wrappedInstance: NSURL

  init(_ wrappedInstance: NSURL) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class GlobalsWrapper: NSObject {
  @objc static public func urlFuncWrapper(url: NSURLWrapper) -> NSURLWrapper {
    let result = urlFunc(url: url.wrappedInstance)
    return NSURLWrapper(result)
  }

}

