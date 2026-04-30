package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public abstract interface TestClass73<T>  extends List<String> {
  <S> long getFoo(long p1);
  public static record NestedRecord(int x) {}

}
