// Test preamble text

import Foundation

@objc public class MyCustomStructWrapper: NSObject {
  var wrappedInstance: MyCustomStruct

  @objc public var data: Int {
    get {
      wrappedInstance.data
    }
    set {
      wrappedInstance.data = newValue
    }
  }

  init(_ wrappedInstance: MyCustomStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(value: Int) {
    wrappedInstance = MyCustomStruct(value: value)
  }

}

@objc public class MyStaticStructWrapper: NSObject {
  var wrappedInstance: MyStaticStruct

  @objc static public var defaultName: String {
    get {
      MyStaticStruct.defaultName
    }
    set {
      MyStaticStruct.defaultName = newValue
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

  init(_ wrappedInstance: MyStaticStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(name: String) {
    wrappedInstance = MyStaticStruct(name: name)
  }

}

@objc public class MyComputedStructWrapper: NSObject {
  var wrappedInstance: MyComputedStruct

  @objc public var fullName: String {
    get {
      wrappedInstance.fullName
    }
  }

  @objc public var lastName: String {
    get {
      wrappedInstance.lastName
    }
    set {
      wrappedInstance.lastName = newValue
    }
  }

  @objc public var firstName: String {
    get {
      wrappedInstance.firstName
    }
    set {
      wrappedInstance.firstName = newValue
    }
  }

  init(_ wrappedInstance: MyComputedStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(firstName: String, lastName: String) {
    wrappedInstance = MyComputedStruct(firstName: firstName, lastName: lastName)
  }

}

@objc public class MyConfigWrapper: NSObject {
  var wrappedInstance: MyConfig

  @objc public var count: Int {
    get {
      wrappedInstance.count
    }
    set {
      wrappedInstance.count = newValue
    }
  }

  @objc public var title: String {
    get {
      wrappedInstance.title
    }
    set {
      wrappedInstance.title = newValue
    }
  }

  @objc public var enabled: Bool {
    get {
      wrappedInstance.enabled
    }
    set {
      wrappedInstance.enabled = newValue
    }
  }

  init(_ wrappedInstance: MyConfig) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(title: String, count: Int, enabled: Bool) {
    wrappedInstance = MyConfig(title: title, count: count, enabled: enabled)
  }

}

@objc public class MyPersonWrapper: NSObject {
  var wrappedInstance: MyPerson

  @objc public var age: Int {
    get {
      wrappedInstance.age
    }
    set {
      wrappedInstance.age = newValue
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

  init(_ wrappedInstance: MyPerson) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(name: String, age: Int) {
    wrappedInstance = MyPerson(name: name, age: age)
  }

}

