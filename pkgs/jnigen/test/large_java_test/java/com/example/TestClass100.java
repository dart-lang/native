package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.setFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.int_
public sealed interface TestClass100<T, U>  {
  default int[] setFoo() { return null; }
  public enum NestedEnum { V1 }

  public static final class Sub<T, U> implements TestClass100<T, U> {}
}
