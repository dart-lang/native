import Foundation

public class MyClass {
  public init(y: Int) throws {}

  public var classGetter: MyClass {
    get throws {
        try MyClass(y: 3)
    }
  }
  public var otherClassGetter: OtherClass {
    get throws {
        OtherClass()
    }
  }
}

public class OtherClass {}

public var globalClassGetter: MyClass {
    get throws {
        try MyClass(y: 4)
    }
}
public var globalOtherClassGetter: OtherClass {
    get throws {
        OtherClass()
    }
}
