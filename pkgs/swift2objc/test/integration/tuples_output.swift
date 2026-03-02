// Test preamble text

import Foundation

@objc public class TupleTestWrapper: NSObject {
  var wrappedInstance: TupleTest

  init(_ wrappedInstance: TupleTest) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func getLabeledTuple() -> Tuple_id_Int_name_String {
    let result = wrappedInstance.getLabeledTuple()
    return Tuple_id_Int_name_String(result)
  }

  @objc public func getAllLabeledTuple() -> Tuple_x_Int_y_Int_z_String {
    let result = wrappedInstance.getAllLabeledTuple()
    return Tuple_x_Int_y_Int_z_String(result)
  }

  @objc public func getDeeplyNestedTuple() -> Tuple_Int_StringBoolDouble {
    let result = wrappedInstance.getDeeplyNestedTuple()
    return Tuple_Int_StringBoolDouble(result)
  }

  @objc public func getRepeatedNestedTuple() -> Tuple_IntString_IntString {
    let result = wrappedInstance.getRepeatedNestedTuple()
    return Tuple_IntString_IntString(result)
  }

  @objc public func getLargeTuple() -> Tuple_Int_Int_Int_Int_Int {
    let result = wrappedInstance.getLargeTuple()
    return Tuple_Int_Int_Int_Int_Int(result)
  }

  @objc public func getMixedTuple() -> Tuple_Int_value_String_Bool {
    let result = wrappedInstance.getMixedTuple()
    return Tuple_Int_value_String_Bool(result)
  }

  @objc public func getNothing() {
    return wrappedInstance.getNothing()
  }

  @objc public func getCoordinates() -> Tuple_Int_Int {
    let result = wrappedInstance.getCoordinates()
    return Tuple_Int_Int(result)
  }

  @objc public func getSingleValue() -> Int {
    return wrappedInstance.getSingleValue()
  }

  @objc public class NestedTupleTestWrapper: NSObject {
    var wrappedInstance: TupleTest.NestedTupleTest

    init(_ wrappedInstance: TupleTest.NestedTupleTest) {
      self.wrappedInstance = wrappedInstance
    }

    @objc public func getNestedTuple() -> Tuple_Int_StringBool {
      let result = wrappedInstance.getNestedTuple()
      return Tuple_Int_StringBool(result)
    }

  }

}

@objc public class Tuple_Bool_Double: NSObject {
  var wrappedInstance: (Bool, Double)

  @objc public var _0: Bool {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: Double {
    get {
      wrappedInstance.1
    }
    set {
      wrappedInstance.1 = newValue
    }
  }

  init(_ wrappedInstance: (Bool, Double)) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_IntString_IntString: NSObject {
  var wrappedInstance: ((Int, String), (Int, String))

  @objc public var _0: Tuple_Int_String {
    get {
      Tuple_Int_String(wrappedInstance.0)
    }
    set {
      wrappedInstance.0 = newValue.wrappedInstance
    }
  }

  @objc public var _1: Tuple_Int_String {
    get {
      Tuple_Int_String(wrappedInstance.1)
    }
    set {
      wrappedInstance.1 = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: ((Int, String), (Int, String))) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_Int_Int: NSObject {
  var wrappedInstance: (Int, Int)

  @objc public var _0: Int {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: Int {
    get {
      wrappedInstance.1
    }
    set {
      wrappedInstance.1 = newValue
    }
  }

  init(_ wrappedInstance: (Int, Int)) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_Int_Int_Int_Int_Int: NSObject {
  var wrappedInstance: (Int, Int, Int, Int, Int)

  @objc public var _0: Int {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: Int {
    get {
      wrappedInstance.1
    }
    set {
      wrappedInstance.1 = newValue
    }
  }

  @objc public var _2: Int {
    get {
      wrappedInstance.2
    }
    set {
      wrappedInstance.2 = newValue
    }
  }

  @objc public var _3: Int {
    get {
      wrappedInstance.3
    }
    set {
      wrappedInstance.3 = newValue
    }
  }

  @objc public var _4: Int {
    get {
      wrappedInstance.4
    }
    set {
      wrappedInstance.4 = newValue
    }
  }

  init(_ wrappedInstance: (Int, Int, Int, Int, Int)) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_Int_String: NSObject {
  var wrappedInstance: (Int, String)

  @objc public var _0: Int {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: String {
    get {
      wrappedInstance.1
    }
    set {
      wrappedInstance.1 = newValue
    }
  }

  init(_ wrappedInstance: (Int, String)) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_Int_StringBool: NSObject {
  var wrappedInstance: (Int, (String, Bool))

  @objc public var _0: Int {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: Tuple_String_Bool {
    get {
      Tuple_String_Bool(wrappedInstance.1)
    }
    set {
      wrappedInstance.1 = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: (Int, (String, Bool))) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_Int_StringBoolDouble: NSObject {
  var wrappedInstance: (Int, (String, (Bool, Double)))

  @objc public var _0: Int {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: Tuple_String_BoolDouble {
    get {
      Tuple_String_BoolDouble(wrappedInstance.1)
    }
    set {
      wrappedInstance.1 = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: (Int, (String, (Bool, Double)))) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_Int_value_String_Bool: NSObject {
  var wrappedInstance: (Int, value: String, Bool)

  @objc public var _0: Int {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var value: String {
    get {
      wrappedInstance.value
    }
    set {
      wrappedInstance.value = newValue
    }
  }

  @objc public var _2: Bool {
    get {
      wrappedInstance.2
    }
    set {
      wrappedInstance.2 = newValue
    }
  }

  init(_ wrappedInstance: (Int, value: String, Bool)) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_String_Bool: NSObject {
  var wrappedInstance: (String, Bool)

  @objc public var _0: String {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: Bool {
    get {
      wrappedInstance.1
    }
    set {
      wrappedInstance.1 = newValue
    }
  }

  init(_ wrappedInstance: (String, Bool)) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_String_BoolDouble: NSObject {
  var wrappedInstance: (String, (Bool, Double))

  @objc public var _0: String {
    get {
      wrappedInstance.0
    }
    set {
      wrappedInstance.0 = newValue
    }
  }

  @objc public var _1: Tuple_Bool_Double {
    get {
      Tuple_Bool_Double(wrappedInstance.1)
    }
    set {
      wrappedInstance.1 = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: (String, (Bool, Double))) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_id_Int_name_String: NSObject {
  var wrappedInstance: (id: Int, name: String)

  @objc public var id: Int {
    get {
      wrappedInstance.id
    }
    set {
      wrappedInstance.id = newValue
    }
  }

  @objc public var name: String {
    get {
      wrappedInstance.name
    }
    set {
      wrappedInstance.name = newValue
    }
  }

  init(_ wrappedInstance: (id: Int, name: String)) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class Tuple_x_Int_y_Int_z_String: NSObject {
  var wrappedInstance: (x: Int, y: Int, z: String)

  @objc public var x: Int {
    get {
      wrappedInstance.x
    }
    set {
      wrappedInstance.x = newValue
    }
  }

  @objc public var y: Int {
    get {
      wrappedInstance.y
    }
    set {
      wrappedInstance.y = newValue
    }
  }

  @objc public var z: String {
    get {
      wrappedInstance.z
    }
    set {
      wrappedInstance.z = newValue
    }
  }

  init(_ wrappedInstance: (x: Int, y: Int, z: String)) {
    self.wrappedInstance = wrappedInstance
  }

}

