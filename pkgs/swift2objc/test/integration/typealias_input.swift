public typealias Foo = Int;
public typealias Bar = MyClass;

public class MyClass {
  public typealias Baz = Bar;

  public func method(x: Baz) -> Foo { return 123; }
}
