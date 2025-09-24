// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../visitor/ast.dart';
import 'binding.dart';
import 'binding_string.dart';
import 'compound.dart';
import 'imports.dart';
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
  final bool loadFromNativeAsset;
  final bool constant;

  Global({
    super.usr,
    super.originalName,
    required super.name,
    required this.type,
    super.dartDoc,
    this.exposeSymbolAddress = false,
    this.constant = false,
    this.loadFromNativeAsset = false,
  });

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final globalVarName = name;
    s.write(makeDartDoc(dartDoc));
    final context = w.context;
    final dartType = type.getDartType(context);
    final ffiDartType = type.getFfiDartType(context);

    // Removing pointer reference for ConstantArray cType since we always wrap
    // globals with pointer below.
    final cType = (type is ConstantArray && !loadFromNativeAsset)
        ? (type as ConstantArray).child.getCType(context)
        : type.getCType(context);

    final ptrType = '${context.libs.prefix(ffiImport)}.Pointer<$cType>';

    void generateConvertingGetterAndSetter(String pointerValue) {
      final getValue = type.convertFfiDartTypeToDartType(
        context,
        pointerValue,
        objCRetain: true,
      );
      s.write('$dartType get $globalVarName => $getValue;\n\n');
      if (!constant) {
        final releaseOldValue = type.convertFfiDartTypeToDartType(
          context,
          pointerValue,
          objCRetain: false,
        );
        final newValue = type.convertDartTypeToFfiDartType(
          context,
          'value',
          objCRetain: true,
          objCAutorelease: false,
        );
        s.write('''set $globalVarName($dartType value) {
  $releaseOldValue.ref.release();
  $pointerValue = $newValue;
}''');
      }
    }

    if (loadFromNativeAsset) {
      if (type case final ConstantArray arr) {
        s.writeln(makeArrayAnnotation(w, arr));
      }

      final pointerName = type.sameDartAndFfiDartType
          ? globalVarName
          : context.rootNamespace.addPrivate('_$globalVarName');

      s
        ..writeln(
          makeNativeAnnotation(
            w,
            nativeType: cType,
            dartName: pointerName,
            nativeSymbolName: originalName,
            isLeaf: false,
          ),
        )
        ..write('external ');
      if (constant) {
        s.write('final ');
      }

      s.writeln('$ffiDartType $pointerName;\n');

      if (!type.sameDartAndFfiDartType) {
        generateConvertingGetterAndSetter(pointerName);
      }

      if (exposeSymbolAddress) {
        w.symbolAddressWriter.addNativeSymbol(type: ptrType, name: name);
      }
    } else {
      final pointerName = context.rootNamespace.addPrivate('_$globalVarName');
      final lookupFn = context.extraSymbols.lookupFuncName!.name;

      s.write(
        'late final $ptrType $pointerName = '
        "$lookupFn<$cType>('$originalName');\n\n",
      );
      final baseTypealiasType = type.typealiasType;
      if (baseTypealiasType is Compound) {
        if (baseTypealiasType.isOpaque) {
          s.write('$ptrType get $globalVarName => $pointerName;\n\n');
        } else {
          s.write('$ffiDartType get $globalVarName => $pointerName.ref;\n\n');
        }
      } else if (baseTypealiasType is ConstantArray) {
        s.write('$ffiDartType get $globalVarName => $pointerName;\n\n');
      } else if (type.sameDartAndFfiDartType) {
        s.write('$dartType get $globalVarName => $pointerName.value;\n\n');
        if (!constant) {
          s.write(
            'set $globalVarName($dartType value) =>'
            '$pointerName.value = value;\n\n',
          );
        }
      } else {
        generateConvertingGetterAndSetter('$pointerName.value');
      }

      if (exposeSymbolAddress) {
        // Add to SymbolAddress in writer.
        w.symbolAddressWriter.addSymbol(
          type: ptrType,
          name: name,
          ptrName: pointerName,
        );
      }
    }

    return BindingString(type: BindingStringType.global, string: s.toString());
  }

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(type);
    visitor.visit(ffiImport);
    if (loadFromNativeAsset && exposeSymbolAddress) {
      visitor.visit(selfImport);
    }
  }

  @override
  void visit(Visitation visitation) => visitation.visitGlobal(this);
}
