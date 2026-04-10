package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.byte_
public interface TestClass124  extends Runnable, Cloneable {
  default <S extends Number> byte[] getFoo(byte[] p1) { return null; }
  public static record NestedRecord(int x) {}

}
