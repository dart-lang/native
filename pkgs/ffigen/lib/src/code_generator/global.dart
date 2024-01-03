// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config_provider/config_types.dart';
import 'binding.dart';
import 'binding_string.dart';
import 'compound.dart';
import 'pointer.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding to a global variable
///
/// For a C global variable -
/// ```c
/// int a;
/// ```
/// The generated dart code is -
/// ```dart
/// final int a = _dylib.lookup<ffi.Int32>('a').value;
/// ```
class Global extends LookUpBinding {
  final Type type;
  final bool exposeSymbolAddress;
  final FfiNativeConfig nativeConfig;
  final bool constant;

  Global({
    super.usr,
    super.originalName,
    required super.name,
    required this.type,
    super.dartDoc,
    this.exposeSymbolAddress = false,
    this.constant = false,
    this.nativeConfig = const FfiNativeConfig(enabled: false),
  });

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final globalVarName = name;
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    final dartType = type.getFfiDartType(w);
    final cType = type.getCType(w);

    if (nativeConfig.enabled) {
      if (type case final ConstantArray arr) {
        s.writeln(makeArrayAnnotation(w, arr));
      }

      s
        ..writeln(makeNativeAnnotation(
          w,
          nativeType: cType,
          assetId: nativeConfig.assetId,
          dartName: globalVarName,
          nativeSymbolName: originalName,
          isLeaf: false,
        ))
        ..write('external ');
      if (constant) {
        s.write('final ');
      }

      s.writeln('$dartType $globalVarName;\n');

      if (exposeSymbolAddress) {
        w.symbolAddressWriter.addNativeSymbol(
            type: '${w.ffiLibraryPrefix}.Pointer<$cType>', name: name);
      }
    } else {
      final pointerName =
          w.wrapperLevelUniqueNamer.makeUnique('_$globalVarName');

      s.write(
          "late final ${w.ffiLibraryPrefix}.Pointer<$cType> $pointerName = ${w.lookupFuncIdentifier}<$cType>('$originalName');\n\n");
      final baseTypealiasType = type.typealiasType;
      if (baseTypealiasType is Compound) {
        if (baseTypealiasType.isOpaque) {
          s.write(
              '${w.ffiLibraryPrefix}.Pointer<$cType> get $globalVarName => $pointerName;\n\n');
        } else {
          s.write('$dartType get $globalVarName => $pointerName.ref;\n\n');
        }
      } else {
        s.write('$dartType get $globalVarName => $pointerName.value;\n\n');
        if (!constant) {
          s.write(
              'set $globalVarName($dartType value) => $pointerName.value = value;\n\n');
        }
      }

      if (exposeSymbolAddress) {
        // Add to SymbolAddress in writer.
        w.symbolAddressWriter.addSymbol(
          type: '${w.ffiLibraryPrefix}.Pointer<$cType>',
          name: name,
          ptrName: pointerName,
        );
      }
    }

    return BindingString(type: BindingStringType.global, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    type.addDependencies(dependencies);
  }
}
