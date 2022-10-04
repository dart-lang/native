// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

// Very specific to JNI: Here `X` is vtable class if X contains function pointer
// members invoked with first argument of type `X**`.
const vtableClasses = {"JNIInvokeInterface": "JavaVM"};

// Y is extension class if it contains function pointer fields which are
// otherwise equivalent to normal functions, and just packed in a structure
// for convenience.
const extensionClasses = {'GlobalJniEnv', 'JniAccessors'};

const methodNameRenames = {"throw": "throwException"};

enum CompoundType { struct, union }

/// A binding for Compound type - Struct/Union.
abstract class Compound extends BindingType {
  /// Marker for if a struct definition is complete.
  ///
  /// A function can be safely pass this struct by value if it's complete.
  bool isIncomplete;

  List<Member> members;

  bool get isOpaque => members.isEmpty;

  /// Value for `@Packed(X)` annotation. Can be null (no packing), 1, 2, 4, 8,
  /// or 16.
  ///
  /// Only supported for [CompoundType.struct].
  int? pack;

  /// Marker for checking if the dependencies are parsed.
  bool parsedDependencies = false;

  CompoundType compoundType;
  bool get isStruct => compoundType == CompoundType.struct;
  bool get isUnion => compoundType == CompoundType.union;

  Compound({
    String? usr,
    String? originalName,
    required String name,
    required this.compoundType,
    this.isIncomplete = false,
    this.pack,
    String? dartDoc,
    List<Member>? members,
    bool isInternal = false,
  })  : members = members ?? [],
        super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
          isInternal: isInternal,
        );

  factory Compound.fromType({
    required CompoundType type,
    String? usr,
    String? originalName,
    required String name,
    bool isIncomplete = false,
    int? pack,
    String? dartDoc,
    List<Member>? members,
  }) {
    switch (type) {
      case CompoundType.struct:
        return Struct(
          usr: usr,
          originalName: originalName,
          name: name,
          isIncomplete: isIncomplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
        );
      case CompoundType.union:
        return Union(
          usr: usr,
          originalName: originalName,
          name: name,
          isIncomplete: isIncomplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
        );
    }
  }

  List<int> _getArrayDimensionLengths(Type type) {
    final array = <int>[];
    var startType = type;
    while (startType is ConstantArray) {
      array.add(startType.length);
      startType = startType.child;
    }
    return array;
  }

  String _getInlineArrayTypeString(Type type, Writer w) {
    if (type is ConstantArray) {
      return '${w.ffiLibraryPrefix}.Array<'
          '${_getInlineArrayTypeString(type.child, w)}>';
    }
    return type.getCType(w);
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final es = StringBuffer();
    final isVtable = vtableClasses.containsKey(name);
    final isExt = extensionClasses.contains(name);
    final toExtend = isVtable || isExt;
    late String ptrTypeString; // need this later
    final enclosingClassName = name;
    if (toExtend) {
      final ffi = w.ffiLibraryPrefix;
      if (isVtable) {
        final ptrType = vtableClasses[name]!;
        ptrTypeString = "$ffi.Pointer<$ptrType>";
      } else {
        ptrTypeString = "$ffi.Pointer<$name>";
      }
      es.write(
          "extension ${enclosingClassName}Extension on $ptrTypeString {\n");
    }
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    final voidPointer =
        "${w.ffiLibraryPrefix}.Pointer<${w.ffiLibraryPrefix}.Void>";

    /// Adding [enclosingClassName] because dart doesn't allow class member
    /// to have the same name as the class.
    final localUniqueNamer = UniqueNamer({enclosingClassName});

    /// Marking type names because dart doesn't allow class member to have the
    /// same name as a type name used internally.
    for (final m in members) {
      localUniqueNamer.markUsed(m.type.getDartType(w));
    }

    /// Write @Packed(X) annotation if struct is packed.
    if (isStruct && pack != null) {
      s.write('@${w.ffiLibraryPrefix}.Packed($pack)\n');
    }
    final dartClassName = isStruct ? 'Struct' : 'Union';
    // Write class declaration.
    s.write('class $enclosingClassName extends ');
    s.write('${w.ffiLibraryPrefix}.${isOpaque ? 'Opaque' : dartClassName}{\n');
    const depth = '  ';
    for (final m in members) {
      m.name = localUniqueNamer.makeUnique(m.name);
      if (m.type is ConstantArray) {
        s.write('$depth@${w.ffiLibraryPrefix}.Array.multi(');
        s.write('${_getArrayDimensionLengths(m.type)})\n');
        s.write('${depth}external ${_getInlineArrayTypeString(m.type, w)} ');
        s.write('${m.name};\n\n');
      } else {
        if (m.dartDoc != null) {
          s.write(depth + '/// ');
          s.writeAll(m.dartDoc!.split('\n'), '\n' + depth + '/// ');
          s.write('\n');
        }
        if (!sameDartAndCType(m.type, w)) {
          s.write('$depth@${m.type.getCType(w)}()\n');
        }
        final isPointer = (m.type is PointerType);
        final isFunctionPointer =
            isPointer && (m.type as PointerType).child is NativeFunc;

        final hasVarArgListParam = isFunctionPointer && m.name.endsWith('V');

        if (toExtend && isFunctionPointer) {
          final nf = (m.type as PointerType).child as NativeFunc;
          final fnType = nf.type as FunctionType;

          if (hasVarArgListParam) {
            s.write('${depth}external $voidPointer _${m.name};\n\n');
            continue;
          }

          s.write('${depth}external ${m.type.getDartType(w)} ${m.name};\n\n');
          final extensionParams = fnType.parameters.toList(); // copy
          final implicitThis = isVtable;
          if (implicitThis) {
            extensionParams.removeAt(0);
          }
          if (m.dartDoc != null) {
            es.write('$depth/// ');
            es.writeAll(m.dartDoc!.split('\n'), '\n$depth/// ');
            es.write('\n');
            es.write("$depth///\n"
                "$depth/// This is an automatically generated extension method\n");
          }
          es.write("$depth${fnType.returnType.getDartType(w)} ${m.name}(");
          final visibleParams = <String>[];
          final actualParams = <String>[if (implicitThis) "this"];
          final callableFnType = fnType.getDartType(w);

          for (int i = 0; i < extensionParams.length; i++) {
            final p = extensionParams[i];
            final paramName = p.name.isEmpty
                ? (m.params != null
                    ? m.params![i + (implicitThis ? 1 : 0)]
                    : "arg$i")
                : p.name;
            visibleParams.add("${p.type.getDartType(w)} $paramName");
            actualParams.add(paramName);
          }

          es.write("${visibleParams.join(', ')}) {\n");
          final ref = isVtable ? 'value.ref' : 'ref';
          es.write(
              "$depth${depth}return $ref.${m.name}.asFunction<$callableFnType>()(");
          es.write(actualParams.join(", "));
          es.write(");\n$depth}\n\n");
        } else {
          final memberName = hasVarArgListParam ? '_${m.name}' : m.name;
          final memberType =
              hasVarArgListParam ? voidPointer : m.type.getDartType(w);
          s.write('${depth}external $memberType $memberName;\n\n');
        }
      }
    }
    if (toExtend) {
      es.write("}\n\n");
    }
    s.write('}\n\n');

    return BindingString(
        type: isStruct ? BindingStringType.struct : BindingStringType.union,
        string: s.toString() + es.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    for (final m in members) {
      m.type.addDependencies(dependencies);
    }
  }

  @override
  bool get isIncompleteCompound => isIncomplete;

  @override
  String getCType(Writer w) => name;
}

class Member {
  final String? dartDoc;
  final String originalName;
  String name;
  final Type type;
  final List<String>? params;

  Member({
    String? originalName,
    required this.name,
    required this.type,
    this.dartDoc,
    this.params,
  }) : originalName = originalName ?? name;
}
