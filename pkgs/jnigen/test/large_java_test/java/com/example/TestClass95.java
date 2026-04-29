package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.float_
public interface TestClass95<T, U>  extends List<String> {
  default <S> float getFoo(float p1) { return 0.0f; }
  public static interface Nested {}

}
