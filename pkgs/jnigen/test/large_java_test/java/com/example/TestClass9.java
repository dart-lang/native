package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.implements_, IsArray: IsArray.yes, Member: Member.constructor, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.none, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.record, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public record TestClass9<T extends Number>(Map.Entry<T, T>[] field)  implements Runnable {
  public void run() {}
}
