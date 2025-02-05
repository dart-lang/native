// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlinx.metadata.Flag;
import kotlinx.metadata.KmFunction;
import kotlinx.metadata.jvm.JvmExtensionsKt;

public class KotlinFunction {
  /** Name in the byte code. */
  public String name;

  public String descriptor;

  /** Name in the Kotlin's metadata. */
  public String kotlinName;

  public List<KotlinValueParameter> valueParameters;
  public KotlinType returnType;
  public KotlinType receiverParameterType;
  public List<KotlinType> contextReceiverTypes;
  public List<KotlinTypeParameter> typeParameters;
  public int flags;
  public boolean isSuspend;
  public boolean isOperator;

  public static KotlinFunction fromKmFunction(KmFunction f) {
    var fun = new KotlinFunction();
    var signature = JvmExtensionsKt.getSignature(f);
    fun.descriptor = signature == null ? null : signature.getDesc();
    fun.name = signature == null ? null : signature.getName();
    fun.kotlinName = f.getName();
    fun.flags = f.getFlags();
    // Processing the information needed from the flags.
    fun.isSuspend = Flag.Function.IS_SUSPEND.invoke(fun.flags);
    fun.isOperator = Flag.Function.IS_OPERATOR.invoke(fun.flags);
    fun.valueParameters =
        f.getValueParameters().stream()
            .map(KotlinValueParameter::fromKmValueParameter)
            .collect(Collectors.toList());
    fun.returnType = KotlinType.fromKmType(f.getReturnType());
    fun.receiverParameterType = KotlinType.fromKmType(f.getReceiverParameterType());
    fun.contextReceiverTypes =
        f.getContextReceiverTypes().stream()
            .map(KotlinType::fromKmType)
            .collect(Collectors.toList());
    fun.typeParameters =
        f.getTypeParameters().stream()
            .map(KotlinTypeParameter::fromKmTypeParameter)
            .collect(Collectors.toList());
    return fun;
  }
}
