package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public interface TestClass91<T extends Number>  extends Runnable, Cloneable {
  default <S, V> long[] isFoo() { return null; }
  public static record NestedRecord(int x) {}

}
