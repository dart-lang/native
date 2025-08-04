public typealias Foo = Int;
public typealias FooFoo = Foo;
public typealias Bar = MyClass;
public typealias BarBar = Bar;
public typealias BarNullable = Bar?;

public class MyClass {
  public typealias Baz = Bar;

  public func method1(x: Foo) -> FooFoo { return 123; }
  public func method2(x: Bar) -> BarBar { return x; }
  public func method3(x: BarNullable) -> BarNullable { return x; }
  public func method4(x: Baz) -> Baz { return x; }
}
