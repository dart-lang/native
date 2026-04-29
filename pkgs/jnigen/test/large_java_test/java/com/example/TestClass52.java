package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.field, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.none, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.customInterface
public sealed interface TestClass52<T extends Number>  {
  Runnable myField = null;
  public static record NestedRecord(int x) {}

  public static final class Sub<T extends Number> implements TestClass52<T> {}
}
