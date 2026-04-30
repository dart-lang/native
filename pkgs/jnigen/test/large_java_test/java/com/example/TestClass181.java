package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.setFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.string
public interface TestClass181<T extends Number>  extends List<String> {
  default <S> String[] setFoo(String[] p1) { return null; }
  public enum NestedEnum { V1 }

}
