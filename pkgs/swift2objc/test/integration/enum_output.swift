// Test preamble text

import Foundation

@objc public class CompassPointWrapper: NSObject {
  var wrappedInstance: CompassPoint

  @objc static public var east: CompassPointWrapper {
    get {
      CompassPointWrapper(CompassPoint.east)
    }
  }

  @objc static public var west: CompassPointWrapper {
    get {
      CompassPointWrapper(CompassPoint.west)
    }
  }

  @objc static public var north: CompassPointWrapper {
    get {
      CompassPointWrapper(CompassPoint.north)
    }
  }

  @objc static public var south: CompassPointWrapper {
    get {
      CompassPointWrapper(CompassPoint.south)
    }
  }

  init(_ wrappedInstance: CompassPoint) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class TrafficLightWrapper: NSObject {
  var wrappedInstance: TrafficLight

  @objc public var instruction: String {
    get {
      wrappedInstance.instruction
    }
  }

  @objc static public var red: TrafficLightWrapper {
    get {
      TrafficLightWrapper(TrafficLight.red)
    }
  }

  @objc static public var green: TrafficLightWrapper {
    get {
      TrafficLightWrapper(TrafficLight.green)
    }
  }

  @objc static public var yellow: TrafficLightWrapper {
    get {
      TrafficLightWrapper(TrafficLight.yellow)
    }
  }

  init(_ wrappedInstance: TrafficLight) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init?(colorName: String) {
    if let instance = TrafficLight(colorName: colorName) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc public func advance() {
    return wrappedInstance.advance()
  }

}

@objc public class MathConstantsWrapper: NSObject {
  var wrappedInstance: MathConstants

  @objc static public var e: MathConstantsWrapper {
    get {
      MathConstantsWrapper(MathConstants.e)
    }
  }

  @objc static public var pi: MathConstantsWrapper {
    get {
      MathConstantsWrapper(MathConstants.pi)
    }
  }

  @objc static public var phi: MathConstantsWrapper {
    get {
      MathConstantsWrapper(MathConstants.phi)
    }
  }

  @objc static public var gamma: MathConstantsWrapper {
    get {
      MathConstantsWrapper(MathConstants.gamma)
    }
  }

  @objc static public var sqrt2: MathConstantsWrapper {
    get {
      MathConstantsWrapper(MathConstants.sqrt2)
    }
  }

  init(_ wrappedInstance: MathConstants) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init?(rawValue: Float) {
    if let instance = MathConstants(rawValue: rawValue) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

}

@objc public class StatusWrapper: NSObject {
  var wrappedInstance: Status

  @objc static public var failure: StatusWrapper {
    get {
      StatusWrapper(Status.failure)
    }
  }

  @objc static public var success: StatusWrapper {
    get {
      StatusWrapper(Status.success)
    }
  }

  init(_ wrappedInstance: Status) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init?(rawValue: String) {
    if let instance = Status(rawValue: rawValue) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

}

@objc public class BarcodeWrapper: NSObject {
  var wrappedInstance: Barcode

  init(_ wrappedInstance: Barcode) {
    self.wrappedInstance = wrappedInstance
  }

  @objc static public func upc(numberSystem: Int, manufacturer: Int, product: Int, check: Int) -> BarcodeWrapper {
    let result = Barcode.upc(numberSystem: numberSystem, manufacturer: manufacturer, product: product, check: check)
    return BarcodeWrapper(result)
  }

  @objc static public func qrCode(_ arg0: String) -> BarcodeWrapper {
    let result = Barcode.qrCode(arg0)
    return BarcodeWrapper(result)
  }

}

@objc public class BeverageWrapper: NSObject {
  var wrappedInstance: Beverage

  @objc static public var tea: BeverageWrapper {
    get {
      BeverageWrapper(Beverage.tea)
    }
  }

  @objc static public var juice: BeverageWrapper {
    get {
      BeverageWrapper(Beverage.juice)
    }
  }

  @objc static public var coffee: BeverageWrapper {
    get {
      BeverageWrapper(Beverage.coffee)
    }
  }

  init(_ wrappedInstance: Beverage) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class DayOfWeekWrapper: NSObject {
  var wrappedInstance: DayOfWeek

  @objc static public var friday: DayOfWeekWrapper {
    get {
      DayOfWeekWrapper(DayOfWeek.friday)
    }
  }

  @objc static public var monday: DayOfWeekWrapper {
    get {
      DayOfWeekWrapper(DayOfWeek.monday)
    }
  }

  @objc static public var sunday: DayOfWeekWrapper {
    get {
      DayOfWeekWrapper(DayOfWeek.sunday)
    }
  }

  @objc static public var tuesday: DayOfWeekWrapper {
    get {
      DayOfWeekWrapper(DayOfWeek.tuesday)
    }
  }

  @objc static public var saturday: DayOfWeekWrapper {
    get {
      DayOfWeekWrapper(DayOfWeek.saturday)
    }
  }

  @objc static public var thursday: DayOfWeekWrapper {
    get {
      DayOfWeekWrapper(DayOfWeek.thursday)
    }
  }

  @objc static public var wednesday: DayOfWeekWrapper {
    get {
      DayOfWeekWrapper(DayOfWeek.wednesday)
    }
  }

  init(_ wrappedInstance: DayOfWeek) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init?(rawValue: Int) {
    if let instance = DayOfWeek(rawValue: rawValue) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

}

