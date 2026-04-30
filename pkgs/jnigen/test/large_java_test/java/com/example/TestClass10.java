package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.typeParam
public interface TestClass10<T, U>  extends DiamondLeft, DiamondRight {
  default T myMethod() { return null; }
  public static record NestedRecord(int x) {}

}
