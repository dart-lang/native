package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.int_
public sealed interface TestClass135<T, U>  {
  default int[] isFoo(int[] p1, int p2) { return null; }
  public static interface Nested {}

  public static final class Sub<T, U> implements TestClass135<T, U> {}
}
