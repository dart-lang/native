package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public interface TestClass6  extends List {
  default <S, V> Set<S> myMethod() { return null; }
  public enum NestedEnum { V1 }

}
