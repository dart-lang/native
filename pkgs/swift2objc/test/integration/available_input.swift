@available(iOS 100, macOS 123.0.0, *)
public class NewApi {
  @available(iOS 101, macOS 456, *)
  public init(x: Int) {
    prop1 = x;
    prop2 = x;
  }

  public func method1() -> Int { return 123; }

  @available(iOS 100.1, macOS 123.4.5, *)
  public func method2() -> Int { return 123; }

  @available(iOS, unavailable)
  @available(macOS, introduced: 200, deprecated: 201, obsoleted: 202,
      message: "Hello")
  public func method3() -> Int { return 123; }

  public var prop1: Int;

  @available(iOS, introduced: 234.5.6)
  @available(macOS, deprecated: 345.6)
  public var prop2: Int;
}

@available(iOS 100, macOS 123.0.0, *)
public struct NewStruct {
  public func method1() -> Int { return 123; }

  @available(iOS 100.1, macOS 123.4.5, *)
  public func method2() -> Int { return 123; }

  public var prop1: Int;

  @available(iOS, introduced: 234.5.6)
  @available(macOS, deprecated: 345.6)
  public var prop2: Int;
}

@available(iOS 200, macOS 200, *)
public typealias NewerApi = NewApi;

@available(iOS, introduced: 1234.5.6)
@available(macOS, obsoleted: 999)
public var globalVar: Int = 123;

@available(iOS, unavailable)
@available(macOS, introduced: 234.5.6)
public func globalFunc(x: NewerApi) -> Int { return 123; }
