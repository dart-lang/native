package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.field, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.volatile, MemberName: MemberName.any, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.nestedCustom
public sealed class TestClass234<T extends Number>  {
  public volatile NestedCustom<T, T>.Nested<T> myField;
  public static class Nested {}

  public static final class Sub<T extends Number> extends TestClass234<T> {}
}
