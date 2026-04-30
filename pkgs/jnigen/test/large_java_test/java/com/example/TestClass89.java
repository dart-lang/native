package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public interface TestClass89<T extends Number>  extends Runnable, Cloneable {
  default <S extends Number> Set<S>[] isFoo() { return null; }
  public static record NestedRecord(int x) {}

}
