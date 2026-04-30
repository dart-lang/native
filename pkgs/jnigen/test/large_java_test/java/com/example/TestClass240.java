package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.throws, MemberName: MemberName.setFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.byte_
public sealed class TestClass240<T extends Number>  {
  public byte setFoo() throws Exception { return 0; }
  public static interface Nested {}

  public static final class Sub<T extends Number> extends TestClass240<T> {}
}
