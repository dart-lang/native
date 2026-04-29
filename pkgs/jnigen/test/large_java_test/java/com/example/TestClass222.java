package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.throws, MemberName: MemberName.any, NestedKind: NestedKind.interface, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public interface TestClass222<T extends Number>  extends List<String> {
  Set<T>[] myMethod(Set<T>[] p1) throws Exception;
  public static interface Nested {}

}
