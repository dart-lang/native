// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/public_ast.dart' as public_ast;
import '../context.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'local_variables.dart';
import 'scope.dart';
import 'utils.dart';
import 'writer.dart';

enum CppMethodKind { constructor, method }

/// A method or constructor belonging to a C++ class.
class CppMethod extends AstNode with HasLocalScope {
  final Symbol name;
  final String originalName;

  /// The Dart-facing name of this method in generated code.
  ///
  /// Defaults to [originalName]. Can be changed via a visitor to rename the
  /// method in the generated Dart class without affecting the glue symbol.
  String dartName;

  final Type returnType;
  final List<Parameter> parameters;
  final bool isConstant;
  final bool isStatic;
  final CppMethodKind kind;
  final CppClass? originatingClass;

  bool isIncluded = true;

  CppMethod({
    required this.name,
    required this.originalName,
    String? dartName,
    required this.returnType,
    required this.parameters,
    required this.isConstant,
    this.isStatic = false,
    this.kind = CppMethodKind.method,
    this.originatingClass,
  }) : dartName = dartName ?? originalName;

  bool get isConstructor => kind == .constructor;

  CppMethod cloneForClass(CppClass targetClass, CppClass baseClass) {
    return CppMethod(
      name: Symbol(
        '${targetClass.originalName}_$originalName',
        SymbolKind.method,
      ),
      originalName: originalName,
      dartName: dartName,
      returnType: returnType,
      parameters: parameters.map((p) => p.clone()).toList(),
      isConstant: isConstant,
      isStatic: isStatic,
      kind: kind,
      originatingClass: baseClass,
    );
  }

  String signatureKey() {
    final paramTypes = parameters.map((p) => p.type.cacheKey()).join(',');
    final constSuffix = isConstant ? ' const' : '';
    return '$originalName($paramTypes)$constSuffix';
  }

  @override
  void visit(Visitation visitation) => visitation.visitCppMethod(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(name);
    visitor.visit(returnType);
    visitor.visitAll(parameters);
    visitor.visit(originatingClass);
  }
}

class CppMember extends CompoundMember {
  /// Whether this field is declared `const` in the C++ source.
  ///
  /// A const field can only have a getter generated; mutable fields get both
  /// a getter and a setter.
  final bool isConst;

  CppMember({
    super.originalName,
    required super.name,
    required super.type,
    super.dartDoc,
    required this.isConst,
  });
}

/// A binding for a C++ class.
class CppClass extends BindingType with HasLocalScope {
  final Context context;
  final List<CppMethod> methods;
  final List<CppMember> fields;
  bool isIncluded = false;

  /// The public C++ base classes for this class, in declaration order.
  ///
  /// Only public inheritance is represented here. Protected and private bases
  /// are silently ignored by the parser.
  final List<CppClass> bases;

  CppClass({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    required this.context,
    required this.methods,
    required this.fields,
    this.bases = const [],
  });

  @override
  public_ast.AstNode? toPublicAstNode() => public_ast.CppClass(this);

  @override
  void visit(Visitation visitation) => visitation.visitCppClass(this);

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
    required LocalVariables localVariables,
  }) => '$value._ptr';

  void copyMethod(CppMethod method, CppClass originatingBase) {
    final cloned = method.cloneForClass(this, originatingBase);
    methods.add(cloned);
  }

  void filterMethods(bool Function(CppMethod method) predicate) {
    methods.retainWhere(predicate);
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final ctx = w.context;
    final ffiPrefix = ctx.libs.prefix(ffiImport);

    final ptrVoid = '$ffiPrefix.Pointer<$ffiPrefix.Void>';

    // Helper to build a comma-separated Dart parameter list.
    String dartParamList(Iterable<Parameter> params) =>
        params.map((p) => '${p.type.getDartType(ctx)} ${p.name}').join(', ');

    final classMethods = methods.where((m) => m.kind == .method).toList();
    final constructors = methods.where((m) => m.kind == .constructor).toList();

    final deleteSymbol = '${name}_delete';
    final deleteGlue = '_$deleteSymbol';

    s.write(makeDartDoc(dartDoc));
    // Build the implements clause: ffi.Finalizable + public base classes.
    final implementsClause = [
      '$ffiPrefix.Finalizable',
      ...bases.map((b) => b.name),
    ].join(', ');
    s.write('''
class $name implements $implementsClause {
  $ptrVoid _ptr;
''');

    s.write('''
  static final _defaultFinalizer = $ffiPrefix.NativeFinalizer(
    $ffiPrefix.Native.addressOf<$ffiPrefix.NativeFunction<$ffiPrefix.Void Function($ptrVoid)>>($deleteGlue),
  );

  /// The finalizer currently attached for this instance, or [null] if this
  /// object does not own its pointer.
  $ffiPrefix.NativeFinalizer? _activeFinalizer;

  /// The native function pointer used by [_activeFinalizer], stored so that
  /// [dispose] can call the correct destructor directly.
  $ffiPrefix.Pointer<
    $ffiPrefix.NativeFunction<$ffiPrefix.Void Function($ptrVoid)>
  >? _activeFinalizerFn;

  $name.fromPointer(this._ptr, {bool takeOwnership = false}) {
    if (takeOwnership) {
      _defaultFinalizer.attach(this, _ptr.cast(), detach: this);
      _activeFinalizer = _defaultFinalizer;
      _activeFinalizerFn = $ffiPrefix.Native.addressOf<
        $ffiPrefix.NativeFunction<$ffiPrefix.Void Function($ptrVoid)>
      >($deleteGlue);
    }
  }

  /// Attaches a finalizer so this object takes ownership of the underlying
  /// C++ pointer. If [customFinalizer] is provided it is used instead of the
  /// default `delete` finalizer, which is useful when the object was not
  /// allocated with `new` (e.g. `malloc` or a custom allocator).
  ///
  /// Both [customFinalizer] and [customFinalizerFn] must be provided together.
  ///
  /// Throws a [StateError] if the object has already been disposed, or if
  /// this object already owns the pointer.
  void retainOwnership([
    $ffiPrefix.NativeFinalizer? customFinalizer,
    $ffiPrefix.Pointer<
      $ffiPrefix.NativeFunction<$ffiPrefix.Void Function($ptrVoid)>
    >? customFinalizerFn,
  ]) {
    if (_ptr == $ffiPrefix.nullptr) {
      throw StateError('This object has already been disposed.');
    }
    if (_activeFinalizer != null) {
      throw StateError('This object already owns its pointer.');
    }
    if ((customFinalizer == null) != (customFinalizerFn == null)) {
      throw ArgumentError(
          'Both customFinalizer and customFinalizerFn must be provided together.');
    }
    final fin = customFinalizer ?? _defaultFinalizer;
    final fnPtr = customFinalizerFn ??
        $ffiPrefix.Native.addressOf<
          $ffiPrefix.NativeFunction<$ffiPrefix.Void Function($ptrVoid)>
        >($deleteGlue);
    fin.attach(this, _ptr.cast(), detach: this);
    _activeFinalizer = fin;
    _activeFinalizerFn = fnPtr;
  }

  /// Detaches the finalizer so this object releases ownership of the
  /// underlying C++ pointer. The caller becomes responsible for freeing
  /// the memory.
  ///
  /// Throws a [StateError] if the object has already been disposed, or if
  /// this object does not own the pointer.
  void releaseOwnership() {
    if (_ptr == $ffiPrefix.nullptr) {
      throw StateError('This object has already been disposed.');
    }
    if (_activeFinalizer == null) {
      throw StateError('This object does not own its pointer.');
    }
    _activeFinalizer!.detach(this);
    _activeFinalizer = null;
    _activeFinalizerFn = null;
  }

  /// Detaches the finalizer and invalidates this object, returning the
  /// underlying C++ pointer.
  ///
  /// Throws a [StateError] if the object has already been disposed, or if
  /// this object does not own the pointer.
  $ptrVoid detachPointer() {
    final rawPtr = _ptr;
    releaseOwnership();
    _ptr = $ffiPrefix.nullptr;
    return rawPtr;
  }
''');

    for (final ctor in constructors) {
      final glueName = ctor.name.name;
      final privateName = '_$glueName';

      final dartParams = dartParamList(ctor.parameters);
      final localVars = LocalVariables(ctor.localScope);

      final callArgs = ctor.parameters
          .map(
            (p) => p.type.convertDartTypeToFfiDartType(
              ctx,
              p.name,
              objCRetain: false,
              objCAutorelease: false,
              localVariables: localVars,
            ),
          )
          .join(', ');

      s.write('''
  factory $name($dartParams) {
    ${localVars.generateDeclarations()}
    return $name.fromPointer($privateName($callArgs), takeOwnership: true);
  }
''');
    }

    for (final method in classMethods) {
      final glue = '_${method.name.name}';
      final dartReturn = method.returnType.getDartType(ctx);
      final dartParams = dartParamList(method.parameters);
      final localVars = LocalVariables(method.localScope);

      final callArgs = [
        if (!method.isStatic) '_ptr',
        ...method.parameters.map(
          (p) => p.type.convertDartTypeToFfiDartType(
            ctx,
            p.name,
            objCRetain: false,
            objCAutorelease: false,
            localVariables: localVars,
          ),
        ),
      ].join(', ');
      final decls = localVars.generateDeclarations();

      final returnExpr = method.returnType.convertFfiDartTypeToDartType(
        ctx,
        '$glue($callArgs)',
        objCRetain: false,
      );

      final hasReturn = method.returnType != voidType;
      final callLine = hasReturn ? 'return $returnExpr;' : '$returnExpr;';

      if (method.isStatic) {
        s.write('''\
  static $dartReturn ${method.dartName}($dartParams) {
    $decls
    $callLine
  }
''');
      } else {
        s.write('''\
  $dartReturn ${method.dartName}($dartParams) {
    if (_ptr == $ffiPrefix.nullptr) {
      throw StateError('This object has already been disposed.');
    }
    $decls
    $callLine
  }
''');
      }
    }
    s.write('''
  ${bases.isNotEmpty ? '@override\n  ' : ''}void dispose() {
    if (_ptr == $ffiPrefix.nullptr) {
      throw StateError('This object has already been disposed.');
    }
    if (_activeFinalizer == null) {
      throw StateError('Cannot dispose a non-owning wrapper. '
          'Call retainOwnership() first to take ownership.');
    }
    _activeFinalizer!.detach(this);
    _activeFinalizer = null;
    _activeFinalizerFn?.asFunction<void Function($ptrVoid)>()(_ptr);
    _activeFinalizerFn = null;
    _ptr = $ffiPrefix.nullptr;
  }
''');

    s.write('}\n');

    // Writes a @Native annotation + external declaration for a glue function.
    void writeNativeDecl({
      required String symbol,
      required String glue,
      required String cType,
      required String ffiReturn,
      required String ffiParams,
    }) {
      s.write(
        makeNativeAnnotation(
          w,
          nativeType: cType,
          dartName: glue,
          nativeSymbolName: Namer.cSafeName(symbol),
        ),
      );
      s.write('\nexternal $ffiReturn $glue($ffiParams);\n\n');
    }

    for (final method in methods) {
      final symbol = method.name.name;
      final glue = '_$symbol';

      final cReturn = method.isConstructor
          ? ptrVoid
          : method.returnType.getCType(ctx);
      final ffiReturn = method.isConstructor
          ? ptrVoid
          : method.returnType.getFfiDartType(ctx);

      final needsSelf = !method.isConstructor && !method.isStatic;
      final cParams = [
        if (needsSelf) ptrVoid,
        ...method.parameters.map((p) => p.type.getCType(ctx)),
      ].join(', ');
      final ffiParams = [
        if (needsSelf) '$ptrVoid self',
        ...method.parameters.map(
          (p) => '${p.type.getFfiDartType(ctx)} ${p.name}',
        ),
      ].join(', ');

      writeNativeDecl(
        symbol: symbol,
        glue: glue,
        cType: '$cReturn Function($cParams)',
        ffiReturn: ffiReturn,
        ffiParams: ffiParams,
      );
    }
    writeNativeDecl(
      symbol: deleteSymbol,
      glue: deleteGlue,
      cType: '$ffiPrefix.Void Function($ptrVoid)',
      ffiReturn: 'void',
      ffiParams: '$ptrVoid self',
    );

    return BindingString(
      type: BindingStringType.cppClass,
      string: s.toString(),
    );
  }

  @override
  String? toCppBindingString(Writer w) {
    final context = w.context;
    String paramDecl(Parameter p) =>
        p.type.getNativeType(context, varName: p.name).trim();

    final deleteWrapper =
        '''
FFIGEN_EXPORT void ${name}_delete($originalName* self) {
  delete self;
}''';

    final methodBindings = methods
        .map((method) {
          final symbol = method.name.name;

          final String returnTypeString;
          final String params;
          final String body;

          final callArgs = method.parameters.map(_cppCallArg).join(', ');

          if (method.isConstructor) {
            returnTypeString = '$originalName*';
            params = method.parameters.map(paramDecl).join(', ');
            body = 'return new $originalName($callArgs);';
          } else {
            final nativeType = method.returnType.getNativeType(context);
            returnTypeString = nativeType.trim();
            final needsReturn = method.returnType != voidType;
            final returnPrefix = needsReturn ? 'return ' : '';

            final otherParams = method.parameters.map(paramDecl);

            if (method.isStatic) {
              final targetType =
                  method.originatingClass?.originalName ?? originalName;
              params = otherParams.join(', ');
              body =
                  '$returnPrefix$targetType::'
                  '${method.originalName}($callArgs);';
            } else {
              final constPrefix = method.isConstant ? 'const ' : '';
              final selfType = '$constPrefix$originalName';
              params = ['$selfType* self', ...otherParams].join(', ');
              final methodName = method.originalName;
              final suffix = method.returnType is CppUniquePtrType
                  ? '.release()'
                  : '';
              body = '${returnPrefix}self->$methodName($callArgs)$suffix;';
            }
          }

          return '''
FFIGEN_EXPORT $returnTypeString $symbol($params) {
  $body
}''';
        })
        .join('\n\n');

    return '$methodBindings\n\n$deleteWrapper\n\n';
  }

  @override
  String getCType(Context context) => name;

  @override
  String getNativeType(Context context, {String varName = ''}) =>
      varName.isEmpty ? originalName : '$originalName $varName';

  @override
  bool get sameFfiDartAndCType => true;
  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  bool get hasNativeHelperFunctions => true;

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(methods);
    visitor.visitAll(fields);
    visitor.visitAll(bases);
    visitor.visit(ffiImport);
  }
}

String _cppCallArg(Parameter p) {
  final type = p.type;
  if (type is CppUniquePtrType) {
    final className = type.cppClass.originalName;
    return 'std::unique_ptr<$className>(${p.name})';
  }
  return p.name;
}
