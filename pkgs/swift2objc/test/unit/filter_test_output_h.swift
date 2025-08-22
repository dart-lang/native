// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func listGarageVehiclesWrapper(garage: GarageWrapper) {
    return listGarageVehicles(garage: garage.wrappedInstance)
  }

}

// This wrapper is a stub. To generate the full wrapper, add Garage
// to your config's include function.
@objc public class GarageWrapper: NSObject {
  var wrappedInstance: Garage

  init(_ wrappedInstance: Garage) {
    self.wrappedInstance = wrappedInstance
  }

}

