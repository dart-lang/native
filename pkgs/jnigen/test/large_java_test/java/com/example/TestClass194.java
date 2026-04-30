package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.boolean_
public interface TestClass194<T extends Number>  extends List {
  default <S> boolean[] getFoo(boolean[] p1, int p2) { return null; }
  public enum NestedEnum { V1 }

}
