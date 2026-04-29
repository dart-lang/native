package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.setFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.list
public sealed interface TestClass101<T, U>  {
  default List<T>[] setFoo() { return null; }
  public enum NestedEnum { V1 }

  public static final class Sub<T, U> implements TestClass101<T, U> {}
}
