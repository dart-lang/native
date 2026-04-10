package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.class_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.object
public interface TestClass10  extends List {
  default <S, V> Object[] myMethod() { return null; }
  public static class Nested {}

}
