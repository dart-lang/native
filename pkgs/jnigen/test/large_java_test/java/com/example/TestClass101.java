package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extends_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public interface TestClass101<T, U>  extends Runnable {
  default <S extends Number> NestedCustom<S, S>.Nested<S> getFoo(NestedCustom<S, S>.Nested<S> p1) { return null; }
  public enum NestedEnum { V1 }

}
