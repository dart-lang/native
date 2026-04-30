package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.isFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.char_
public abstract interface TestClass65  extends DiamondLeft, DiamondRight {
  <S extends Number> char[] isFoo(char[] p1);
  public enum NestedEnum { V1 }

}
