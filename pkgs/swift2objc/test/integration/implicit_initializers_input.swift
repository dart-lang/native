public struct MyPerson {
  public var name: String
  public var age: Int
}

public struct MyConfig {
  public var title: String
  public var count: Int
  public var enabled: Bool
}

public struct MyCustomStruct {
  public var data: Int
  
  public init(value: Int) {
    self.data = value * 2
  }
}

public struct MyStaticStruct {
  public static var defaultName = "Default"
  public var name: String
}

public struct MyComputedStruct {
  public var firstName: String
  public var lastName: String
  public var fullName: String {
    return "\(firstName) \(lastName)"
  }
}
