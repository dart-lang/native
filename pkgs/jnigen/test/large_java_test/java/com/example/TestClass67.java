package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.double_
public interface TestClass67<T>  extends List<String> {
  default <S> double isFoo(double p1, int p2) { return 0.0; }
  public enum NestedEnum { V1 }

}
