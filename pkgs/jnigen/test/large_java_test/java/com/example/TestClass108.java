package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.class_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.short_
public interface TestClass108<T>  extends DiamondLeft, DiamondRight {
  default <S> short[] getFoo(short[] p1) { return null; }
  public static class Nested {}

}
