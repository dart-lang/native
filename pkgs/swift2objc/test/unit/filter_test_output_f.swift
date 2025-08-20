// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func openDoorWrapper(door: GarageWrapper.DoorWrapper) {
    return openDoor(door: door.wrappedInstance)
  }

}

// This wrapper is a stub. To generate the full wrapper, add Garage
// to your config's include function.
@objc public class GarageWrapper: NSObject {
  var wrappedInstance: Garage

  init(_ wrappedInstance: Garage) {
    self.wrappedInstance = wrappedInstance
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

