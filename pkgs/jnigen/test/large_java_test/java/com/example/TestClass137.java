package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.set
public sealed interface TestClass137<T, U>  {
  default Set<T>[] isFoo(Set<T>[] p1, int p2) { return null; }
  public static interface Nested {}

  public static final class Sub<T, U> implements TestClass137<T, U> {}
}
