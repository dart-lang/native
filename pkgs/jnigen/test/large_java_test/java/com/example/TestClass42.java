package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customObject
public interface TestClass42<T>  extends List {
  default ArrayList<T>[] getFoo() { return null; }
}
