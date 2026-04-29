package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.static_, MemberName: MemberName.any, NestedKind: NestedKind.interface, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public interface TestClass42<T extends Number>  extends List {
  static <S extends Number> long[] myMethod() { return null; }
  public static interface Nested {}

}
