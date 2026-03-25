// Test preamble text

import Foundation

@objc public class TrafficLightWrapper: NSObject {
  var wrappedInstance: TrafficLight

  @objc public var instruction: Array<String> {
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

}

@objc public class MyEnumWrapper: NSObject {
  var wrappedInstance: MyEnum

  init(_ wrappedInstance: MyEnum) {
    self.wrappedInstance = wrappedInstance
  }

  @objc static public func dictionary(_ arg0: Dictionary<Int, Int>) -> MyEnumWrapper {
    let result = MyEnum.dictionary(arg0)
    return MyEnumWrapper(result)
  }

  @objc static public func set(_ arg0: Set<Int>) -> MyEnumWrapper {
    let result = MyEnum.set(arg0)
    return MyEnumWrapper(result)
  }

  @objc static public func array(_ arg0: Array<Int>) -> MyEnumWrapper {
    let result = MyEnum.array(arg0)
    return MyEnumWrapper(result)
  }

}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass

  @objc public var customArray: Array<Int> {
    get {
      wrappedInstance.customArray
    }
    set {
      wrappedInstance.customArray = newValue
    }
  }

  @objc public var customDictionary: Dictionary<Int, String> {
    get {
      wrappedInstance.customDictionary
    }
    set {
      wrappedInstance.customDictionary = newValue
    }
  }

  @objc public var nestedGenericVar: Array<Dictionary<Int, Set<String>>>? {
    get {
      wrappedInstance.nestedGenericVar
    }
    set {
      wrappedInstance.nestedGenericVar = newValue
    }
  }

  @objc public var customSet: Set<String> {
    get {
      wrappedInstance.customSet
    }
    set {
      wrappedInstance.customSet = newValue
    }
  }

  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(customArray: Array<Int>, customDictionary: Dictionary<Int, String>, customSet: Set<String>) {
    wrappedInstance = MyClass(customArray: customArray, customDictionary: customDictionary, customSet: customSet)
  }

  @objc public func getLabeledTuple() -> Tuple_id_Array_Array_IntOptional_name_Set_StringOptional {
    let result = wrappedInstance.getLabeledTuple()
    return Tuple_id_Array_Array_IntOptional_name_Set_StringOptional(result)
  }

  @objc public func nestedGenericMethod(param1: Set<Array<Int>>, param2: Dictionary<String, Set<Int>>?) -> Array<Dictionary<Int, Set<String>>>? {
    return wrappedInstance.nestedGenericMethod(param1: param1, param2: param2)
  }

  @objc public func myMethod(label1 param1: Array<String>?, param2: Dictionary<String, String>?, _ param3: Set<Int>, param4: Array<Int>?) -> Array<Bool> {
    return wrappedInstance.myMethod(label1: param1, param2: param2, param3, param4: param4)
  }

}

@objc public class Tuple_id_Array_Array_IntOptional_name_Set_StringOptional: NSObject {
  var wrappedInstance: (id: Array<Array<Int>>?, name: Set<String>?)

  @objc public var id: Array<Array<Int>>? {
    get {
      wrappedInstance.id
    }
    set {
      wrappedInstance.id = newValue
    }
  }

  @objc public var name: Set<String>? {
    get {
      wrappedInstance.name
    }
    set {
      wrappedInstance.name = newValue
    }
  }

  init(_ wrappedInstance: (id: Array<Array<Int>>?, name: Set<String>?)) {
    self.wrappedInstance = wrappedInstance
  }

}

