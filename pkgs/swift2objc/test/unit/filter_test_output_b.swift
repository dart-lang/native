// Test preamble text

import Foundation

@objc public class DimensionsWrapper: NSObject {
  var wrappedInstance: Dimensions

  @objc public var width: Double {
    get {
      wrappedInstance.width
    }
  }

  @objc public var height: Double {
    get {
      wrappedInstance.height
    }
  }

  @objc public var length: Double {
    get {
      wrappedInstance.length
    }
  }

  init(_ wrappedInstance: Dimensions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(length: Double, width: Double, height: Double) {
    wrappedInstance = Dimensions(length: length, width: width, height: height)
  }

  @objc public func displayDimensions() {
    return wrappedInstance.displayDimensions()
  }

}

@objc public class ElectricCarWrapper: NSObject {
  var wrappedInstance: ElectricCar

  @objc public var batteryCapacity: Int {
    get {
      wrappedInstance.batteryCapacity
    }
    set {
      wrappedInstance.batteryCapacity = newValue
    }
  }

  init(_ wrappedInstance: ElectricCar) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func chargeBattery() {
    return wrappedInstance.chargeBattery()
  }

}

@objc public class CarWrapper: NSObject {
  var wrappedInstance: Car

  @objc public var numberOfDoors: Int {
    get {
      wrappedInstance.numberOfDoors
    }
    set {
      wrappedInstance.numberOfDoors = newValue
    }
  }

  init(_ wrappedInstance: Car) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func honk() {
    return wrappedInstance.honk()
  }

}

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
    return wrappedInstance.displaySpecs()
  }

}

@objc public class GarageWrapper: NSObject {
  var wrappedInstance: Garage

  init(_ wrappedInstance: Garage) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Garage()
  }

  @objc public func addVehicle(_ vehicle: VehicleWrapper) {
    return wrappedInstance.addVehicle(vehicle.wrappedInstance)
  }

  @objc public func listVehicles() {
    return wrappedInstance.listVehicles()
  }

}

@objc public class BicycleWrapper: NSObject {
  var wrappedInstance: Bicycle

  @objc public var dimensions: DimensionsWrapper {
    get {
      DimensionsWrapper(wrappedInstance.dimensions)
    }
    set {
      wrappedInstance.dimensions = newValue.wrappedInstance
    }
  }

  @objc public var brand: String {
    get {
      wrappedInstance.brand
    }
    set {
      wrappedInstance.brand = newValue
    }
  }

  @objc public var gearCount: Int {
    get {
      wrappedInstance.gearCount
    }
    set {
      wrappedInstance.gearCount = newValue
    }
  }

  init(_ wrappedInstance: Bicycle) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(brand: String, gearCount: Int, dimensions: DimensionsWrapper) {
    wrappedInstance = Bicycle(brand: brand, gearCount: gearCount, dimensions: dimensions.wrappedInstance)
  }

  @objc public func pedal() {
    return wrappedInstance.pedal()
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

  @objc init(make: String, model: String, engine: EngineWrapper, dimensions: DimensionsWrapper) {
    wrappedInstance = Vehicle(make: make, model: model, engine: engine.wrappedInstance, dimensions: dimensions.wrappedInstance)
  }

  @objc public func displayInfo() {
    return wrappedInstance.displayInfo()
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

  @objc init(make: String, model: String, engine: EngineWrapper, dimensions: DimensionsWrapper) {
    wrappedInstance = Vehicle(make: make, model: model, engine: engine.wrappedInstance, dimensions: dimensions.wrappedInstance)
  }

  @objc public func displayInfo() {
    return wrappedInstance.displayInfo()
  }

}

