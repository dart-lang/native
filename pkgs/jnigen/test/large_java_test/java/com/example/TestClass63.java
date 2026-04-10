package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.implements_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.float_
public interface TestClass63<T, U>  extends Cloneable {
  default <S extends Number> float isFoo() { return 0.0f; }
  public static record NestedRecord(int x) {}

}
