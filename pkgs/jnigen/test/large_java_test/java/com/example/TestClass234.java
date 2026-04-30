package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customRecord
public interface TestClass234<T extends Number>  extends List<String> {
  default <S extends Number> CoreRecord[] myMethod(CoreRecord[] p1) { return null; }
  public static record NestedRecord(int x) {}

}
