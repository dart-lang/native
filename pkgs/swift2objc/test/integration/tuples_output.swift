// Test preamble text

import Foundation

@objc public class TupleTestWrapper: NSObject {
  var wrappedInstance: TupleTest

  init(_ wrappedInstance: TupleTest) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getLabeledTuple() -> Tuple_id_Int_name_String {
    let result = wrappedInstance.getLabeledTuple()
    return Tuple_id_Int_name_String(id: result.id, name: result.name)
  }

  @objc public func getAllLabeledTuple() -> Tuple_x_Int_y_Int_z_String {
    let result = wrappedInstance.getAllLabeledTuple()
    return Tuple_x_Int_y_Int_z_String(x: result.x, y: result.y, z: result.z)
  }

  @objc public func getDeeplyNestedTuple() -> operatorOverload {
    let result = wrappedInstance.getDeeplyNestedTuple()
    return operatorOverload(_0: result.0, _1: operatorOverload1(_0: result.1.0, _1: Tuple_Bool_Double(_0: result.1.1.0, _1: result.1.1.1)))
  }

  @objc public func getTupleWithOptionals() -> Tuple_IntOptional_StringOptional {
    let result = wrappedInstance.getTupleWithOptionals()
    return Tuple_IntOptional_StringOptional(_0: result.0, _1: result.1)
  }

  @objc public func getLargeTuple() -> Tuple_Int_Int_Int_Int_Int {
    let result = wrappedInstance.getLargeTuple()
    return Tuple_Int_Int_Int_Int_Int(_0: result.0, _1: result.1, _2: result.2, _3: result.3, _4: result.4)
  }

  @objc public func getMixedTuple() -> Tuple_Int_value_String_Bool {
    let result = wrappedInstance.getMixedTuple()
    return Tuple_Int_value_String_Bool(_0: result.0, value: result.value, _2: result.2)
  }

  @objc public func getCoordinates() -> Tuple_Int_Int {
    let result = wrappedInstance.getCoordinates()
    return Tuple_Int_Int(_0: result.0, _1: result.1)
  }

  @objc public class NestedTupleTestWrapper: NSObject {
    var wrappedInstance: TupleTest.NestedTupleTest

    init(_ wrappedInstance: TupleTest.NestedTupleTest) {
      self.wrappedInstance = wrappedInstance
    }

    @objc public func getNestedTuple() -> operatorOverload1 {
      let result = wrappedInstance.getNestedTuple()
      return operatorOverload1(_0: result.0, _1: Tuple_String_Bool3(_0: result.1.0, _1: result.1.1))
    }

  }

  @objc public class OptionalTupleTestWrapper: NSObject {
    var wrappedInstance: TupleTest.OptionalTupleTest

    init(_ wrappedInstance: TupleTest.OptionalTupleTest) {
      self.wrappedInstance = wrappedInstance
    }

    @objc public func getOptionalNestedTuple() -> operatorOverload {
      let result = wrappedInstance.getOptionalNestedTuple()
      return operatorOverload(_0: result.0, _1: result.1 == nil ? nil : Tuple_String_Bool1(_0: result.1!.0, _1: result.1!.1))
    }

    @objc public func getOptionalTuple() -> Tuple_Int_String? {
      let result = wrappedInstance.getOptionalTuple()
      return result == nil ? nil : Tuple_Int_String(_0: result!.0, _1: result!.1)
    }

  }

}

@objc public class Tuple_Bool_Double {
  public let _0: Bool

  public let _1: Double

  @objc init(_0: Bool, _1: Double) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_IntOptional_StringOptional {
  public let _0: Int?

  public let _1: String?

  @objc init(_0: Int?, _1: String?) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_Int_Int {
  public let _0: Int

  public let _1: Int

  @objc init(_0: Int, _1: Int) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_Int_Int_Int_Int_Int {
  public let _0: Int

  public let _1: Int

  public let _2: Int

  public let _3: Int

  public let _4: Int

  @objc init(_0: Int, _1: Int, _2: Int, _3: Int, _4: Int) {
    self._0 = _0
    self._1 = _1
    self._2 = _2
    self._3 = _3
    self._4 = _4
  }

}

@objc public class Tuple_Int_String {
  public let _0: Int

  public let _1: String

  @objc init(_0: Int, _1: String) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_Int_value_String_Bool {
  public let _0: Int

  public let value: String

  public let _2: Bool

  @objc init(_0: Int, value: String, _2: Bool) {
    self._0 = _0
    self.value = value
    self._2 = _2
  }

}

@objc public class Tuple_String_Bool {
  public let _0: String

  public let _1: Bool

  @objc init(_0: String, _1: Bool) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_String_Bool1 {
  public let _0: String

  public let _1: Bool

  @objc init(_0: String, _1: Bool) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_String_Bool2 {
  public let _0: String

  public let _1: Bool

  @objc init(_0: String, _1: Bool) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_String_Bool3 {
  public let _0: String

  public let _1: Bool

  @objc init(_0: String, _1: Bool) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class Tuple_id_Int_name_String {
  public let id: Int

  public let name: String

  @objc init(id: Int, name: String) {
    self.id = id
    self.name = name
  }

}

@objc public class Tuple_x_Int_y_Int_z_String {
  public let x: Int

  public let y: Int

  public let z: String

  @objc init(x: Int, y: Int, z: String) {
    self.x = x
    self.y = y
    self.z = z
  }

}

@objc public class operatorOverload {
  public let _0: Int

  public let _1: Tuple_String_Bool?

  @objc init(_0: Int, _1: Tuple_String_Bool?) {
    self._0 = _0
    self._1 = _1
  }

}

@objc public class operatorOverload1 {
  public let _0: Int

  public let _1: Tuple_String_Bool2

  @objc init(_0: Int, _1: Tuple_String_Bool2) {
    self._0 = _0
    self._1 = _1
  }

}

