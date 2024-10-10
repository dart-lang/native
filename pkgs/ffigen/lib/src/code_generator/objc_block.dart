// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../header_parser/data.dart' show bindingsIndex;

import 'ast.dart';
import 'binding_string.dart';
import 'writer.dart';

class ObjCBlock extends BindingType {
  final ObjCBuiltInFunctions builtInFunctions;
  Type returnType;
  final List<Parameter> params;
  final bool returnsRetained;
  ObjCListenerBlockTrampoline? _wrapListenerBlock;

  factory ObjCBlock({
    required Type returnType,
    required List<Parameter> params,
    required bool returnsRetained,
    required ObjCBuiltInFunctions builtInFunctions,
  }) {
    final renamedParams = [
      for (var i = 0; i < params.length; ++i)
        Parameter(
          name: 'arg$i',
          type: params[i].type,
          objCConsumed: params[i].objCConsumed,
        ),
    ];

    final usr = _getBlockUsr(returnType, renamedParams, returnsRetained);

    final oldBlock = bindingsIndex.getSeenObjCBlock(usr);
    if (oldBlock != null) {
      return oldBlock;
    }

    final block = ObjCBlock._(
      usr: usr,
      name: _getBlockName(returnType, renamedParams.map((a) => a.type)),
      returnType: returnType,
      params: renamedParams,
      returnsRetained: returnsRetained,
      builtInFunctions: builtInFunctions,
    );
    bindingsIndex.addObjCBlockToSeen(usr, block);

    return block;
  }

  ObjCBlock._({
    required String super.usr,
    required super.name,
    required this.returnType,
    required this.params,
    required this.returnsRetained,
    required this.builtInFunctions,
  }) : super(originalName: name);

  // Generates a human readable name for the block based on the args and return
  // type. These names will be pretty verbose and unweildy, but they're at least
  // sensible and stable. Users can always add their own typedef with a simpler
  // name if necessary.
  static String _getBlockName(Type returnType, Iterable<Type> argTypes) =>
      'ObjCBlock_${[returnType, ...argTypes].map(_typeName).join('_')}';
  static String _typeName(Type type) =>
      type.toString().replaceAll(_illegalNameChar, '');
  static final _illegalNameChar = RegExp(r'[^0-9a-zA-Z]');

  static String _getBlockUsr(
      Type returnType, List<Parameter> params, bool returnsRetained) {
    // Create a fake USR code for the block. This code is used to dedupe blocks
    // with the same signature. Not intended to be human readable.
    final usr = StringBuffer();
    usr.write(
        'objcBlock: ${returnType.cacheKey()} ${returnsRetained ? 'R' : ''}');
    for (final param in params) {
      usr.write(' ${param.type.cacheKey()} ${param.objCConsumed ? 'C' : ''}');
    }
    return usr.toString();
  }

  bool get hasListener => returnType == voidType;

  String _blockType(Writer w) {
    final argStr = params.map((param) {
      final type = param.type.getObjCBlockSignatureType(w);
      return param.objCConsumed
          ? '${ObjCBuiltInFunctions.consumedType.gen(w)}<$type>'
          : type;
    }).join(', ');
    final retType = returnType.getObjCBlockSignatureType(w);
    final retStr = returnsRetained
        ? '${ObjCBuiltInFunctions.retainedType.gen(w)}<$retType>'
        : retType;
    final func = '$retStr Function($argStr)';
    return '${ObjCBuiltInFunctions.blockType.gen(w)}<$func>';
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    final voidPtr = PointerType(voidType).getCType(w);
    final blockPtr = PointerType(objCBlockType);
    final funcType = FunctionType(returnType: returnType, parameters: params);
    final natFnType = NativeFunc(funcType);
    final natFnPtr = PointerType(natFnType).getCType(w);
    final funcPtrTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_fnPtrTrampoline');
    final closureTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_closureTrampoline');
    final funcPtrCallable =
        w.topLevelUniqueNamer.makeUnique('_${name}_fnPtrCallable');
    final closureCallable =
        w.topLevelUniqueNamer.makeUnique('_${name}_closureCallable');
    final listenerTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_listenerTrampoline');
    final listenerCallable =
        w.topLevelUniqueNamer.makeUnique('_${name}_listenerCallable');
    final callExtension =
        w.topLevelUniqueNamer.makeUnique('${name}_CallExtension');
    final newPointerBlock = ObjCBuiltInFunctions.newPointerBlock.gen(w);
    final newClosureBlock = ObjCBuiltInFunctions.newClosureBlock.gen(w);
    final getBlockClosure = ObjCBuiltInFunctions.getBlockClosure.gen(w);
    final releaseFn = ObjCBuiltInFunctions.objectRelease.gen(w);
    final trampFuncType = FunctionType(returnType: returnType, parameters: [
      Parameter(type: blockPtr, name: 'block', objCConsumed: false),
      ...params
    ]);
    final trampFuncCType = trampFuncType.getCType(w, writeArgumentNames: false);
    final trampFuncFfiDartType =
        trampFuncType.getFfiDartType(w, writeArgumentNames: false);
    final natTrampFnType = NativeFunc(trampFuncType).getCType(w);
    final nativeCallableType =
        '${w.ffiLibraryPrefix}.NativeCallable<$trampFuncCType>';
    final funcDartType = funcType.getDartType(w, writeArgumentNames: false);
    final funcFfiDartType =
        funcType.getFfiDartType(w, writeArgumentNames: false);
    final returnFfiDartType = returnType.getFfiDartType(w);
    final blockCType = blockPtr.getCType(w);
    final blockType = _blockType(w);
    final defaultValue = returnType.getDefaultValue(w);
    final exceptionalReturn = defaultValue == null ? '' : ', $defaultValue';

    final paramsNameOnly = params.map((p) => p.name).join(', ');
    final paramsFfiDartType =
        params.map((p) => '${p.type.getFfiDartType(w)} ${p.name}').join(', ');
    final paramsDartType =
        params.map((p) => '${p.type.getDartType(w)} ${p.name}').join(', ');

    // Write the function pointer based trampoline function.
    s.write('''
$returnFfiDartType $funcPtrTrampoline($blockCType block, $paramsFfiDartType) =>
    block.ref.target.cast<${natFnType.getFfiDartType(w)}>()
        .asFunction<$funcFfiDartType>()($paramsNameOnly);
$voidPtr $funcPtrCallable = ${w.ffiLibraryPrefix}.Pointer.fromFunction<
    $trampFuncCType>($funcPtrTrampoline $exceptionalReturn).cast();
''');

    // Write the closure based trampoline function.
    s.write('''
$returnFfiDartType $closureTrampoline($blockCType block, $paramsFfiDartType) =>
    ($getBlockClosure(block) as $funcFfiDartType)($paramsNameOnly);
$voidPtr $closureCallable = ${w.ffiLibraryPrefix}.Pointer.fromFunction<
    $trampFuncCType>($closureTrampoline $exceptionalReturn).cast();
''');

    if (hasListener) {
      // Write the listener trampoline function.
      s.write('''
$returnFfiDartType $listenerTrampoline($blockCType block, $paramsFfiDartType) {
  ($getBlockClosure(block) as $funcFfiDartType)($paramsNameOnly);
  $releaseFn(block.cast());
}
$nativeCallableType $listenerCallable = $nativeCallableType.listener(
    $listenerTrampoline $exceptionalReturn)..keepIsolateAlive = false;
''');
    }

    // Snippet that converts a Dart typed closure to FfiDart type. This snippet
    // is used below. Note that the closure being converted is called `fn`.
    final convertedFnArgs = params
        .map((p) => p.type.convertFfiDartTypeToDartType(
              w,
              p.name,
              objCRetain: !p.objCConsumed,
            ))
        .join(', ');
    final convFnInvocation = returnType.convertDartTypeToFfiDartType(
      w,
      'fn($convertedFnArgs)',
      objCRetain: true,
      objCAutorelease: !returnsRetained,
    );
    final convFn = '($paramsFfiDartType) => $convFnInvocation';

    // Write the wrapper class.
    s.write('''

/// Construction methods for `$blockType`.
abstract final class $name {
  /// Returns a block that wraps the given raw block pointer.
  static $blockType castFromPointer($blockCType pointer,
      {bool retain = false, bool release = false}) =>
      $blockType(pointer, retain: retain, release: release);

  /// Creates a block from a C function pointer.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  static $blockType fromFunctionPointer($natFnPtr ptr) =>
      $blockType($newPointerBlock($funcPtrCallable, ptr.cast()),
          retain: false, release: true);

  /// Creates a block from a Dart function.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  static $blockType fromFunction($funcDartType fn) =>
      $blockType($newClosureBlock($closureCallable, $convFn),
          retain: false, release: true);
''');

    // Listener block constructor is only available for void blocks.
    if (hasListener) {
      // This snippet is the same as the convFn above, except that the params
      // don't need to be retained because they've already been retained by
      // _wrapListenerBlock.
      final listenerConvertedFnArgs = params
          .map((p) =>
              p.type.convertFfiDartTypeToDartType(w, p.name, objCRetain: false))
          .join(', ');
      final listenerConvFnInvocation = returnType.convertDartTypeToFfiDartType(
        w,
        'fn($listenerConvertedFnArgs)',
        objCRetain: true,
        objCAutorelease: !returnsRetained,
      );
      final listenerConvFn =
          '($paramsFfiDartType) => $listenerConvFnInvocation';
      final wrapFn = _wrapListenerBlock!.func.name;

      s.write('''

  /// Creates a listener block from a Dart function.
  ///
  /// This is based on FFI's NativeCallable.listener, and has the same
  /// capabilities and limitations. This block can be invoked from any thread,
  /// but only supports void functions, and is not run synchronously. See
  /// NativeCallable.listener for more details.
  ///
  /// Note that unlike the default behavior of NativeCallable.listener, listener
  /// blocks do not keep the isolate alive.
  static $blockType listener($funcDartType fn) {
    final raw = $newClosureBlock(
        $listenerCallable.nativeFunction.cast(), $listenerConvFn);
    final wrapper = $wrapFn(raw);
    $releaseFn(raw.cast());
    return $blockType(wrapper, retain: false, release: true);
  }
''');
    }
    s.write('}\n\n');

    // Call operator extension method.
    s.write('''
/// Call operator for `$blockType`.
extension $callExtension on $blockType {
  ${returnType.getDartType(w)} call($paramsDartType) =>''');
    final callMethodArgs = params
        .map((p) => p.type.convertDartTypeToFfiDartType(
              w,
              p.name,
              objCRetain: p.objCConsumed,
              objCAutorelease: false,
            ))
        .join(', ');
    final callMethodInvocation = '''
ref.pointer.ref.invoke.cast<$natTrampFnType>().asFunction<$trampFuncFfiDartType>()(
    ref.pointer, $callMethodArgs)''';
    s.write(returnType.convertFfiDartTypeToDartType(
      w,
      callMethodInvocation,
      objCRetain: !returnsRetained,
    ));
    s.write(';\n');

    s.write('}\n\n');
    return BindingString(
        type: BindingStringType.objcBlock, string: s.toString());
  }

  @override
  BindingString? toObjCBindingString(Writer w) {
    if (_wrapListenerBlock?.objCBindingsGenerated ?? true) return null;
    _wrapListenerBlock!.objCBindingsGenerated = true;

    final argsReceived = <String>[];
    final retains = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final argName = 'arg$i';
      argsReceived.add(param.getNativeType(varName: argName));
      retains.add(param.type.generateRetain(argName) ?? argName);
    }
    final argStr = argsReceived.join(', ');
    final fnName = _wrapListenerBlock!.func.name;
    final blockName = w.objCLevelUniqueNamer.makeUnique('_ListenerTrampoline');
    final blockTypedef = '${returnType.getNativeType()} (^$blockName)($argStr)';

    final s = StringBuffer();
    s.write('''

typedef $blockTypedef;
$blockName $fnName($blockName block) NS_RETURNS_RETAINED {
  return ^void($argStr) {
    ${generateRetain('block')};
    block(${retains.join(', ')});
  };
}
''');
    return BindingString(
        type: BindingStringType.objcBlock, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);

    returnType.addDependencies(dependencies);
    for (final p in params) {
      p.type.addDependencies(dependencies);
    }

    if (hasListener) {
      _wrapListenerBlock = builtInFunctions.getListenerBlockTrampoline(this);
    }
  }

  @override
  String getCType(Writer w) => PointerType(objCBlockType).getCType(w);

  // We return `ObjCBlockBase<T>` here instead of the code genned wrapper, so
  // that the subtyping rules work as expected.
  // See https://github.com/dart-lang/native/issues/1416 for details.
  @override
  String getDartType(Writer w) => _blockType(w);

  @override
  String getObjCBlockSignatureType(Writer w) => getDartType(w);

  @override
  String getNativeType({String varName = ''}) => 'id $varName';

  @override
  bool get sameFfiDartAndCType => true;

  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) =>
      ObjCInterface.generateGetId(value, objCRetain, objCAutorelease);

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      ObjCInterface.generateConstructor(name, value, objCRetain);

  @override
  String? generateRetain(String value) => 'objc_retainBlock($value)';

  @override
  String toString() =>
      '($returnType (^)(${params.map((p) => p.type.toString()).join(', ')}))';

  @override
  void transformChildren(Transformer transformer) {
    super.transformChildren(transformer);
    returnType = transformer.transform(returnType);
    transformer.transformList(params);
    _wrapListenerBlock = transformer.transformNullable(_wrapListenerBlock);
  }
}
