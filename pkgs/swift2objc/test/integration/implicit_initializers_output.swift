@_exported import implicit_initializers

import Foundation

@objc public class MyComputedStructWrapper: NSObject {
  var wrappedInstance: MyComputedStruct

  @objc public init(_ wrappedInstance: MyComputedStruct) {
    self.wrappedInstance = wrappedInstance
    super.init()
  }

  @objc public init(firstName: String, lastName: String) {
    wrappedInstance = MyComputedStruct(firstName: firstName, lastName: lastName)
    super.init()
  }

  @objc public var firstName: String {
    get {
      return wrappedInstance.firstName
    }
    set {
      wrappedInstance.firstName = newValue
    }
  }

  @objc public var fullName: String {
    return wrappedInstance.fullName
  }

  @objc public var lastName: String {
    get {
      return wrappedInstance.lastName
    }
    set {
      wrappedInstance.lastName = newValue
    }
  }
}

@objc public class MyConfigWrapper: NSObject {
  var wrappedInstance: MyConfig

  @objc public init(_ wrappedInstance: MyConfig) {
    self.wrappedInstance = wrappedInstance
    super.init()
  }

  @objc public init(title: String, count: Int, enabled: Bool) {
    wrappedInstance = MyConfig(title: title, count: count, enabled: enabled)
    super.init()
  }

  @objc public var count: Int {
    get {
      return wrappedInstance.count
    }
    set {
      wrappedInstance.count = newValue
    }
  }

  @objc public var enabled: Bool {
    get {
      return wrappedInstance.enabled
    }
    set {
      wrappedInstance.enabled = newValue
    }
  }

  @objc public var title: String {
    get {
      return wrappedInstance.title
    }
    set {
      wrappedInstance.title = newValue
    }
  }
}

@objc public class MyCustomStructWrapper: NSObject {
  var wrappedInstance: MyCustomStruct

  @objc public init(_ wrappedInstance: MyCustomStruct) {
    self.wrappedInstance = wrappedInstance
    super.init()
  }

  @objc public init(value: Int) {
    wrappedInstance = MyCustomStruct(value: value)
    super.init()
  }

  @objc public var data: Int {
    get {
      return wrappedInstance.data
    }
    set {
      wrappedInstance.data = newValue
    }
  }
}

@objc public class MyPersonWrapper: NSObject {
  var wrappedInstance: MyPerson

  @objc public init(_ wrappedInstance: MyPerson) {
    self.wrappedInstance = wrappedInstance
    super.init()
  }

  @objc public init(name: String, age: Int) {
    wrappedInstance = MyPerson(name: name, age: age)
    super.init()
  }

  @objc public var age: Int {
    get {
      return wrappedInstance.age
    }
    set {
      wrappedInstance.age = newValue
    }
  }

  @objc public var name: String {
    get {
      return wrappedInstance.name
    }
    set {
      wrappedInstance.name = newValue
    }
  }
}

@objc public class MyStaticStructWrapper: NSObject {
  var wrappedInstance: MyStaticStruct

  @objc public init(_ wrappedInstance: MyStaticStruct) {
    self.wrappedInstance = wrappedInstance
    super.init()
  }

  @objc public init(name: String) {
    wrappedInstance = MyStaticStruct(name: name)
    super.init()
  }

  @objc public static var defaultName: String {
    get {
      return MyStaticStruct.defaultName
    }
    set {
      MyStaticStruct.defaultName = newValue
    }
  }

  @objc public var name: String {
    get {
      return wrappedInstance.name
    }
    set {
      wrappedInstance.name = newValue
    }
  }
}
