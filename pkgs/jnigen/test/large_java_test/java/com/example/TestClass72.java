package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.byte_
public final class TestClass72<T, U>  implements Runnable, Cloneable {
  public void run() {}
  public <S extends Number> byte getFoo() { return 0; }
  public static record NestedRecord(int x) {}

}
