// Test preamble text

import Foundation

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
  
  @objc init(make: String, model: String, dimensions: DimensionsWrapper, numberOfDoors: Int, tires: TireWrapper, batteryCapacity: Int) {
    wrappedInstance = ElectricCar(make: make, model: model, dimensions: dimensions.wrappedInstance, numberOfDoors: numberOfDoors, tires: tires.wrappedInstance, batteryCapacity: batteryCapacity)
  }
  
  @objc public func chargeBattery() {
    wrappedInstance.chargeBattery()
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
  
  @objc public var tires: TireWrapper {
    get {
      TireWrapper(wrappedInstance.tires)
    }
    set {
      wrappedInstance.tires = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: Car) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(make: String, model: String, engine: EngineWrapper, dimensions: DimensionsWrapper, numberOfDoors: Int, tires: TireWrapper) {
    wrappedInstance = Car(make: make, model: model, engine: engine.wrappedInstance, dimensions: dimensions.wrappedInstance, numberOfDoors: numberOfDoors, tires: tires.wrappedInstance)
  }
  
  @objc public func honk() {
    wrappedInstance.honk()
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
  
  @objc public func addVehicle(vehicle: VehicleWrapper) {
    wrappedInstance.addVehicle(vehicle: vehicle.wrappedInstance)
  }
  
  @objc public func listVehicles() {
    wrappedInstance.listVehicles()
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
    wrappedInstance.pedal()
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
    wrappedInstance.displayInfo()
  }
}
