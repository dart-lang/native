package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.isFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customRecord
public abstract interface TestClass214<T extends Number>  extends DiamondLeft, DiamondRight {
  CustomRecord<T>[] isFoo();
  public static record NestedRecord(int x) {}

}
