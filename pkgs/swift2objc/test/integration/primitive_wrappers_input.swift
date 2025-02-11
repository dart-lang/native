import Foundation

public class MyClass {
  public var age : Int {
    get throws {
        return 10
    }
  }
  public var name : Float {
    get throws {
        return 1.0
    }
  }
  public var height : Double {
    get throws {
        return 1.0
    }
  }
  public var isTrue : Bool {
    get throws {
        return true
    }
  }

  public func intFunc() throws -> Int {
    return 10
  }
  public func floatFunc() throws -> Float {
    return 1.0
  }
  public func doubleFunc() throws -> Double {
    return 1.0
  }
  public func boolFunc() throws -> Bool {
    return true
  }
}

public var globalVar1 : Int {
  get throws {
    return 10
  }
}
public var globalVar2 : Float {
  get throws {
    return 1.0
  }
}
public var globalVar3 : Double {
  get throws {
    return 1.0
  }
}
public var globalVar4 : Bool {
  get throws {
    return true
  }
}

public func intFunc() throws -> Int {
  return 10
}
public func floatFunc() throws -> Float {
  return 1.0
}
public func doubleFunc() throws -> Double {
  return 1.0
}
public func boolFunc() throws -> Bool {
  return true
}