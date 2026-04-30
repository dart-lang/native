package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.throws, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.typeParam
public final class TestClass43<T>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public <S> T[] getFoo() throws Exception { return null; }
  public static record NestedRecord(int x) {}

}
