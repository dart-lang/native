// Test preamble text

import Foundation

@objc public class EngineWrapper: NSObject {
  var wrappedInstance: Engine
  
  @objc public var horsepower: Int {
    get {
      wrappedInstance.horsepower
    }
  }
  
  @objc public var type: String {
    get {
      wrappedInstance.type
    }
  }
  
  init(_ wrappedInstance: Engine) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(type: String, horsepower: Int) {
    wrappedInstance = Engine(type: type, horsepower: horsepower)
  }
  
  @objc public func displaySpecs() {
    wrappedInstance.displaySpecs()
  }
}
