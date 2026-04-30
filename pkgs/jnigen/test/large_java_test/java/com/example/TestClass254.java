package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customRecord
public interface TestClass254<T extends Number>  extends List<String> {
  <S extends Number> CustomRecord<S>[] myMethod(CustomRecord<S>[] p1);
  public static record NestedRecord(int x) {}

}
