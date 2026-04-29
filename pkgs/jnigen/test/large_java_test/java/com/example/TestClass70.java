package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.static_, MemberName: MemberName.isFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.int_
public interface TestClass70  extends DiamondLeft, DiamondRight {
  static <S extends Number> int[] isFoo(int[] p1) { return null; }
  public enum NestedEnum { V1 }

}
