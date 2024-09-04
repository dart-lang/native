// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config_types.dart';
import '../header_parser/data.dart' show bindingsIndex;

import 'binding_string.dart';
import 'writer.dart';

class ObjCBlock extends BindingType {
  final Type returnType;
  final List<Type> argTypes;
  Func? _wrapListenerBlock;

  factory ObjCBlock({
    required Type returnType,
    required List<Type> argTypes,
  }) {
    final usr = _getBlockUsr(returnType, argTypes);

    final oldBlock = bindingsIndex.getSeenObjCBlock(usr);
    if (oldBlock != null) {
      return oldBlock;
    }

    final block = ObjCBlock._(
      usr: usr,
      name: _getBlockName(returnType, argTypes),
      returnType: returnType,
      argTypes: argTypes,
    );
    bindingsIndex.addObjCBlockToSeen(usr, block);

    return block;
  }

  ObjCBlock._({
    required String super.usr,
    required super.name,
    required this.returnType,
    required this.argTypes,
  }) : super(originalName: name);

  // Generates a human readable name for the block based on the args and return
  // type. These names will be pretty verbose and unweildy, but they're at least
  // sensible and stable. Users can always add their own typedef with a simpler
  // name if necessary.
  static String _getBlockName(Type returnType, List<Type> argTypes) =>
      'ObjCBlock_${[returnType, ...argTypes].map(_typeName).join('_')}';
  static String _typeName(Type type) =>
      type.toString().replaceAll(_illegalNameChar, '');
  static final _illegalNameChar = RegExp(r'[^0-9a-zA-Z]');

  static String _getBlockUsr(Type returnType, List<Type> argTypes) {
    // Create a fake USR code for the block. This code is used to dedupe blocks
    // with the same signature.
    final usr = StringBuffer();
    usr.write('objcBlock: ${returnType.cacheKey()}');
    for (final type in argTypes) {
      usr.write(' ${type.cacheKey()}');
    }
    return usr.toString();
  }

  bool get hasListener => returnType == voidType;

  String _blockType(Writer w) {
    final args = argTypes.map((t) => t.getObjCBlockSignatureType(w)).join(', ');
    final func = '${returnType.getObjCBlockSignatureType(w)} Function($args)';
    return '${ObjCBuiltInFunctions.blockType.gen(w)}<$func>';
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    final params = <Parameter>[];
    for (var i = 0; i < argTypes.length; ++i) {
      params.add(
          Parameter(name: 'arg$i', type: argTypes[i], objCConsumed: false));
    }

    final voidPtr = PointerType(voidType).getCType(w);
    final blockPtr = PointerType(objCBlockType);
    final funcType = FunctionType(returnType: returnType, parameters: params);
    final natFnType = NativeFunc(funcType);
    final natFnPtr = PointerType(natFnType).getCType(w);
    final funcPtrTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_fnPtrTrampoline');
    final closureTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_closureTrampoline');
    final callExtension =
        w.topLevelUniqueNamer.makeUnique('${name}_CallExtension');
    final newPointerBlock = ObjCBuiltInFunctions.newPointerBlock.gen(w);
    final newClosureBlock = ObjCBuiltInFunctions.newClosureBlock.gen(w);
    final getBlockClosure = ObjCBuiltInFunctions.getBlockClosure.gen(w);
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
''');

    // Write the closure based trampoline function.
    s.write('''
$returnFfiDartType $closureTrampoline($blockCType block, $paramsFfiDartType) =>
    ($getBlockClosure(block) as $funcFfiDartType)($paramsNameOnly);
''');

    // Snippet that converts a Dart typed closure to FfiDart type. This snippet
    // is used below. Note that the closure being converted is called `fn`.
    final convertedFnArgs = params
        .map((p) =>
            p.type.convertFfiDartTypeToDartType(w, p.name, objCRetain: true))
        .join(', ');
    final convFnInvocation = returnType.convertDartTypeToFfiDartType(
        w, 'fn($convertedFnArgs)',
        objCRetain: true);
    final convFn = '($paramsFfiDartType) => $convFnInvocation';

    // Write the wrapper class.
    final defaultValue = returnType.getDefaultValue(w);
    final exceptionalReturn = defaultValue == null ? '' : ', $defaultValue';
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
      $blockType($newPointerBlock(
          _cFuncTrampoline ??= ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              $trampFuncCType>($funcPtrTrampoline
                  $exceptionalReturn).cast(), ptr.cast()),
          retain: false, release: true);
  static $voidPtr? _cFuncTrampoline;

  /// Creates a block from a Dart function.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  static $blockType fromFunction($funcDartType fn) =>
      $blockType($newClosureBlock(
          _dartFuncTrampoline ??= ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              $trampFuncCType>($closureTrampoline $exceptionalReturn).cast(),
          $convFn), retain: false, release: true);
  static $voidPtr? _dartFuncTrampoline;
''');

    // Listener block constructor is only available for void blocks.
    if (hasListener) {
      // This snippet is the same as the convFn above, except that the args
      // don't need to be retained because they've already been retained by
      // _wrapListenerBlock.
      final listenerConvertedFnArgs = params
          .map((p) =>
              p.type.convertFfiDartTypeToDartType(w, p.name, objCRetain: false))
          .join(', ');
      final listenerConvFnInvocation = returnType.convertDartTypeToFfiDartType(
          w, 'fn($listenerConvertedFnArgs)',
          objCRetain: true);
      final listenerConvFn =
          '($paramsFfiDartType) => $listenerConvFnInvocation';
      final wrapFn = _wrapListenerBlock?.name;
      final releaseFn = ObjCBuiltInFunctions.objectRelease.gen(w);

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
        (_dartFuncListenerTrampoline ??= $nativeCallableType.listener(
            $closureTrampoline $exceptionalReturn)..keepIsolateAlive =
                false).nativeFunction.cast(), $listenerConvFn);''');
      if (wrapFn != null) {
        s.write('''
    final wrapper = $wrapFn(raw);
    $releaseFn(raw.cast());
    return $blockType(wrapper, retain: false, release: true);''');
      } else {
        s.write('''
    return $blockType(raw, retain: false, release: true);''');
      }
      s.write('''
  }
  static $nativeCallableType? _dartFuncListenerTrampoline;
''');
    }
    s.write('}\n\n');

    // Call operator extension method.
    s.write('''
/// Call operator for `$blockType`.
extension $callExtension on $blockType {
  ${returnType.getDartType(w)} call($paramsDartType) =>''');
    final callMethodArgs = params
        .map((p) =>
            p.type.convertDartTypeToFfiDartType(w, p.name, objCRetain: false))
        .join(', ');
    final callMethodInvocation = '''
ref.pointer.ref.invoke.cast<$natTrampFnType>().asFunction<$trampFuncFfiDartType>()(
    ref.pointer, $callMethodArgs)''';
    s.write(returnType.convertFfiDartTypeToDartType(w, callMethodInvocation,
        objCRetain: false));
    s.write(';\n');

    s.write('}\n\n');
    return BindingString(
        type: BindingStringType.objcBlock, string: s.toString());
  }

  @override
  BindingString? toObjCBindingString(Writer w) {
    if (_wrapListenerBlock == null) return null;

    final argsReceived = <String>[];
    final retains = <String>[];
    for (var i = 0; i < argTypes.length; ++i) {
      final t = argTypes[i];
      final argName = 'arg$i';
      argsReceived.add(t.getNativeType(varName: argName));
      retains.add(t.generateRetain(argName) ?? argName);
    }
    final fnName = _wrapListenerBlock!.name;
    final blockTypedef = w.objCLevelUniqueNamer.makeUnique('ListenerBlock');

    final s = StringBuffer();
    s.write('''

typedef ${getNativeType(varName: blockTypedef)};
$blockTypedef $fnName($blockTypedef block) NS_RETURNS_RETAINED {
  return ^void(${argsReceived.join(', ')}) {
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
    for (final t in argTypes) {
      t.addDependencies(dependencies);
    }

    if (hasListener && argTypes.any((t) => t.generateRetain('') != null)) {
      _wrapListenerBlock = Func(
        name: 'wrapListenerBlock_$name',
        returnType: this,
        parameters: [Parameter(name: 'block', type: this, objCConsumed: false)],
        objCReturnsRetained: true,
        isLeaf: true,
        isInternal: true,
        useNameForLookup: true,
        ffiNativeConfig: const FfiNativeConfig(enabled: true),
      )..addDependencies(dependencies);
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
  String getNativeType({String varName = ''}) {
    final args = argTypes.map<String>((t) => t.getNativeType());
    return '${returnType.getNativeType()} (^$varName)(${args.join(', ')})';
  }

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
  }) =>
      ObjCInterface.generateGetId(value, objCRetain);

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
  String toString() => '($returnType (^)(${argTypes.join(', ')}))';
}
