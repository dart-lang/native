@available(iOS 100, macOS 123.0.0, *)
public class NewApi {
  public func method1() -> Int { return 123; }

  @available(iOS 100.0, macOS 123.4.5, *)
  public func method2() -> Int { return 123; }

  @available(iOS, unavailable)
  @available(macOS, introduced: 200, deprecated: 201, obsoleted: 202,
      message: "Hello")
  public func method3() -> Int { return 123; }
}
