// Test preamble text

import Foundation

// This wrapper is a stub. To generate the full wrapper, add Dimensions
// to your config's include function.
@objc public class DimensionsWrapper: NSObject {
  var wrappedInstance: Dimensions

  init(_ wrappedInstance: Dimensions) {
    self.wrappedInstance = wrappedInstance
  }

}

// This wrapper is a stub. To generate the full wrapper, add Engine
// to your config's include function.
@objc public class EngineWrapper: NSObject {
  var wrappedInstance: Engine

  init(_ wrappedInstance: Engine) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class VehicleWrapper: NSObject {
  var wrappedInstance: Vehicle

  @objc public var dimensions: DimensionsWrapper {
    get {
      DimensionsWrapper(wrappedInstance.dimensions)
    }
    set {
      wrappedInstance.dimensions = newValue.wrappedInstance
    }
  }

  @objc public var make: String {
    get {
      wrappedInstance.make
    }
    set {
      wrappedInstance.make = newValue
    }
  }

  @objc public var model: String {
    get {
      wrappedInstance.model
    }
    set {
      wrappedInstance.model = newValue
    }
  }

  @objc public var engine: EngineWrapper {
    get {
      EngineWrapper(wrappedInstance.engine)
    }
    set {
      wrappedInstance.engine = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: Vehicle) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(make: String, model: String, engine: EngineWrapper, dimensions: DimensionsWrapper) {
    wrappedInstance = Vehicle(make: make, model: model, engine: engine.wrappedInstance, dimensions: dimensions.wrappedInstance)
  }

  @objc public func displayInfo() {
    return wrappedInstance.displayInfo()
  }

}

