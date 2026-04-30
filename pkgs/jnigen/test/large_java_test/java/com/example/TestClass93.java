package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.int_
public interface TestClass93<T>  extends List<String> {
  default <S> int getFoo(int p1) { return 0; }
  public static interface Nested {}

}
