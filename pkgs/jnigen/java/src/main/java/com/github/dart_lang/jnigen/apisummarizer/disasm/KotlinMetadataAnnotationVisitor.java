// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import com.github.dart_lang.jnigen.apisummarizer.elements.KotlinClass;
import com.github.dart_lang.jnigen.apisummarizer.elements.KotlinPackage;
import java.util.ArrayList;
import java.util.List;
import kotlinx.metadata.jvm.KotlinClassHeader;
import kotlinx.metadata.jvm.KotlinClassMetadata;
import org.objectweb.asm.AnnotationVisitor;

/**
 * The format of Kotlin's metadata can be found here:
 * https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-metadata/
 */
public class KotlinMetadataAnnotationVisitor extends AnnotationVisitor {
  private ClassDecl decl;

  private int kind;
  private int[] metadataVersion;
  private List<String> data1 = new ArrayList<>();
  private List<String> data2 = new ArrayList<>();
  private String extraString;
  private String packageName;
  private int extraInt;

  public KotlinMetadataAnnotationVisitor(ClassDecl decl) {
    super(AsmConstants.API);
    this.decl = decl;
  }

  @Override
  public void visit(String name, Object value) {
    switch (name) {
      case "k":
        kind = (int) value;
        return;
      case "mv":
        metadataVersion = (int[]) value;
        return;
      case "xs":
        extraString = (String) value;
        return;
      case "pn":
        packageName = (String) value;
        return;
      case "xi":
        extraInt = (int) value;
    }
  }

  @Override
  public AnnotationVisitor visitArray(String name) {
    List<String> arr;
    switch (name) {
      case "d1":
        arr = data1;
        break;
      case "d2":
        arr = data2;
        break;
      default:
        return super.visitArray(name);
    }
    return new AnnotationVisitor(AsmConstants.API) {
      @Override
      public void visit(String name, Object value) {
        arr.add((String) value);
        super.visit(name, value);
      }
    };
  }

  @Override
  public void visitEnd() {
    var header =
        new KotlinClassHeader(
            kind,
            metadataVersion,
            data1.toArray(String[]::new),
            data2.toArray(String[]::new),
            extraString,
            packageName,
            extraInt);
    var metadata = KotlinClassMetadata.read(header);
    if (metadata instanceof KotlinClassMetadata.Class) {
      decl.kotlinClass =
          KotlinClass.fromKmClass(((KotlinClassMetadata.Class) metadata).toKmClass());
    } else if (metadata instanceof KotlinClassMetadata.FileFacade) {
      decl.kotlinPackage =
          KotlinPackage.fromKmPackage(((KotlinClassMetadata.FileFacade) metadata).toKmPackage());
    } else if (metadata instanceof KotlinClassMetadata.SyntheticClass) {
      // Ignore synthetic classes such as lambdas.
    } else if (metadata instanceof KotlinClassMetadata.MultiFileClassFacade) {
      // Ignore multi-file classes
    } else if (metadata instanceof KotlinClassMetadata.MultiFileClassPart) {
      // Ignore multi-file classes
    } else if (metadata instanceof KotlinClassMetadata.Unknown) {
      // Unsupported
    }
    super.visitEnd();
  }
}
