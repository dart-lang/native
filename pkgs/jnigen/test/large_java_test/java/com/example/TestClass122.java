package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.static_, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.customEnum
public sealed interface TestClass122<T extends Number>  {
  static java.lang.Thread.State getFoo() { return java.lang.Thread.State.NEW; }
  public enum NestedEnum { V1 }

  public static final class Sub<T extends Number> implements TestClass122<T> {}
}
