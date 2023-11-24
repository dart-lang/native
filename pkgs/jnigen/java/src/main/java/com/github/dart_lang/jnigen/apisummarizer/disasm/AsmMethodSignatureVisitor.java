// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.Method;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeParam;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeUsage;
import java.util.ArrayList;
import java.util.List;
import org.objectweb.asm.signature.SignatureVisitor;

public class AsmMethodSignatureVisitor extends SignatureVisitor {
  private final Method method;
  private final List<TypeUsage> paramTypes = new ArrayList<>();

  public AsmMethodSignatureVisitor(Method method) {
    super(AsmConstants.API);
    this.method = method;
  }

  @Override
  public void visitFormalTypeParameter(String name) {
    var typeParam = new TypeParam();
    typeParam.name = name;
    method.typeParams.add(typeParam);
  }

  @Override
  public SignatureVisitor visitClassBound() {
    var typeUsage = new TypeUsage();
    // Method initially has no type parameters. In visitFormalTypeParameter we add them
    // and sequentially visitClassBound and visitInterfaceBound.
    method.typeParams.get(method.typeParams.size() - 1).bounds.add(typeUsage);
    return new AsmTypeUsageSignatureVisitor(typeUsage);
  }

  @Override
  public SignatureVisitor visitInterfaceBound() {
    var typeUsage = new TypeUsage();
    method.typeParams.get(method.typeParams.size() - 1).bounds.add(typeUsage);
    return new AsmTypeUsageSignatureVisitor(typeUsage);
  }

  @Override
  public SignatureVisitor visitReturnType() {
    // Visiting params finished.
    //
    // In case of non-static inner class constructor, there is an extra parent parameter
    // at the beginning which is not accounted for by the signature. So we fill the types
    // for the last [paramTypes.size()] params.
    int startIndex = method.params.size() - paramTypes.size();
    for (int i = 0; i < paramTypes.size(); ++i) {
      method.params.get(startIndex + i).type = paramTypes.get(i);
    }
    return new AsmTypeUsageSignatureVisitor(method.returnType);
  }

  @Override
  public SignatureVisitor visitParameterType() {
    paramTypes.add(new TypeUsage());
    return new AsmTypeUsageSignatureVisitor(paramTypes.get(paramTypes.size() - 1));
  }

  @Override
  public SignatureVisitor visitExceptionType() {
    // Do nothing.
    return new AsmTypeUsageSignatureVisitor(new TypeUsage());
  }
}
