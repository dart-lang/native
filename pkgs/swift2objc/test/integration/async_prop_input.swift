import Foundation

public class MyClass {
  public init(y: Int) async {}

  public var classGetter: MyClass {
    get async {
        await MyClass(y: 3)
    }
  }
  public var otherClassGetter: OtherClass {
    get async throws {
        OtherClass()
    }
  }
}

public class OtherClass {}

public var globalClassGetter: MyClass {
    get async {
        await MyClass(y: 4)
    }
}
public var globalOtherClassGetter: OtherClass {
    get async throws {
        OtherClass()
    }
}
