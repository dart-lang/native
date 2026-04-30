package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.none, MemberName: MemberName.any, NestedKind: NestedKind.none, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public interface TestClass43<T, U>  extends Runnable, Cloneable {
  <S> Set<S>[] myMethod();
}
