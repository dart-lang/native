// Test preamble text

import Foundation

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
      wrappedInstance[index]
    }
    set {
      wrappedInstance[index] = newValue
    }
  }

  init(_ wrappedInstance: SubscriptClass) {
    self.wrappedInstance = wrappedInstance
  }

}

