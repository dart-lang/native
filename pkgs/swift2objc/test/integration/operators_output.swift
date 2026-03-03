// Test preamble text

import Foundation

@objc public class Vec2Wrapper: NSObject {
  var wrappedInstance: Vec2

  @objc public var x: Double {
    get {
      wrappedInstance.x
    }
    set {
      wrappedInstance.x = newValue
    }
  }

  @objc public var y: Double {
    get {
      wrappedInstance.y
    }
    set {
      wrappedInstance.y = newValue
    }
  }

  init(_ wrappedInstance: Vec2) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(x: Double, y: Double) {
    wrappedInstance = Vec2(x: x, y: y)
  }

  @objc static public func add(lhs: Vec2Wrapper, rhs: Vec2Wrapper) -> Vec2Wrapper {
    let result = lhs.wrappedInstance + rhs.wrappedInstance
    return Vec2Wrapper(result)
  }

  @objc static public func equals(lhs: Vec2Wrapper, rhs: Vec2Wrapper) -> Bool {
    return lhs.wrappedInstance == rhs.wrappedInstance
  }

  @objc static public func operatorOverload(lhs: Vec2Wrapper, rhs: Vec2Wrapper) -> Double {
    return lhs.wrappedInstance *** rhs.wrappedInstance
  }

}

