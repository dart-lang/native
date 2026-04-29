package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.map
public interface TestClass129<T extends Number>  extends List<String> {
  default <S extends Number> Map<S, S>[] myMethod(Map<S, S>[] p1, int p2) { return null; }
}
