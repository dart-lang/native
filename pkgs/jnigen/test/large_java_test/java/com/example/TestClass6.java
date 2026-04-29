package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public interface TestClass6  extends List {
  default <S, V> long[] myMethod() { return null; }
  public enum NestedEnum { V1 }

}
