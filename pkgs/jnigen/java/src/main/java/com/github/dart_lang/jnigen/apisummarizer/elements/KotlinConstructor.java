// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlinx.metadata.KmConstructor;
import kotlinx.metadata.jvm.JvmExtensionsKt;

public class KotlinConstructor {
  public String name;
  public String descriptor;
  public List<KotlinValueParameter> valueParameters;
  public int flags;

  public static KotlinConstructor fromKmConstructor(KmConstructor c) {
    var ctor = new KotlinConstructor();
    ctor.flags = c.getFlags();
    var signature = JvmExtensionsKt.getSignature(c);
    ctor.name = signature == null ? null : signature.getName();
    ctor.descriptor = signature == null ? null : signature.getDesc();
    ctor.valueParameters =
        c.getValueParameters().stream()
            .map(KotlinValueParameter::fromKmValueParameter)
            .collect(Collectors.toList());
    return ctor;
  }
}
