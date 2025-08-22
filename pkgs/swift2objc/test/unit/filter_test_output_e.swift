// Test preamble text

import Foundation

// This wrapper is a stub. To generate the full wrapper, add Garage
// to your config's include function.
@objc public class GarageWrapper: NSObject {
  var wrappedInstance: Garage

  init(_ wrappedInstance: Garage) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public class DoorWrapper: NSObject {
    var wrappedInstance: Garage.Door

    @objc public var isOpen: Bool {
      get {
        wrappedInstance.isOpen
      }
      set {
        wrappedInstance.isOpen = newValue
      }
    }

    init(_ wrappedInstance: Garage.Door) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

