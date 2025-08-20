// Test preamble text

import Foundation

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

  // This wrapper is a stub. To generate the full wrapper, add Garage.Door
  // to your config's include function.
  @objc public class DoorWrapper: NSObject {
    var wrappedInstance: Garage.Door

    init(_ wrappedInstance: Garage.Door) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

// This wrapper is a stub. To generate the full wrapper, add Vehicle
// to your config's include function.
@objc public class VehicleWrapper: NSObject {
  var wrappedInstance: Vehicle

  init(_ wrappedInstance: Vehicle) {
    self.wrappedInstance = wrappedInstance
  }

}

