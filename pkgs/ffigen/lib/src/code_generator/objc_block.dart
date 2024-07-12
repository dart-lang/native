// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/data.dart' show bindingsIndex;

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

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    final params = <Parameter>[];
    for (var i = 0; i < argTypes.length; ++i) {
      params.add(Parameter(name: 'arg$i', type: argTypes[i]));
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
    final newPointerBlock = ObjCBuiltInFunctions.newPointerBlock.gen(w);
    final newClosureBlock = ObjCBuiltInFunctions.newClosureBlock.gen(w);
    final getBlockClosure = ObjCBuiltInFunctions.getBlockClosure.gen(w);
    final trampFuncType = FunctionType(
        returnType: returnType,
        parameters: [Parameter(type: blockPtr, name: 'block'), ...params]);
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
class $name extends ${ObjCBuiltInFunctions.blockBase.gen(w)} {
  $name._($blockCType pointer,
      {bool retain = false, bool release = true}) :
          super(pointer, retain: retain, release: release);

  /// Returns a block that wraps the given raw block pointer.
  static $name castFromPointer($blockCType pointer,
      {bool retain = false, bool release = false}) {
    return $name._(pointer, retain: retain, release: release);
  }

  /// Creates a block from a C function pointer.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  $name.fromFunctionPointer($natFnPtr ptr) :
      this._($newPointerBlock(
          _cFuncTrampoline ??= ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              $trampFuncCType>($funcPtrTrampoline
                  $exceptionalReturn).cast(), ptr.cast()));
  static $voidPtr? _cFuncTrampoline;

  /// Creates a block from a Dart function.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  $name.fromFunction($funcDartType fn) :
      this._($newClosureBlock(
          _dartFuncTrampoline ??= ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              $trampFuncCType>($closureTrampoline $exceptionalReturn).cast(),
          $convFn));
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
  $name.listener($funcDartType fn) :
      this._(${_wrapListenerBlock?.name ?? ''}($newClosureBlock(
          (_dartFuncListenerTrampoline ??= $nativeCallableType.listener(
              $closureTrampoline $exceptionalReturn)..keepIsolateAlive =
                  false).nativeFunction.cast(), $listenerConvFn)));
  static $nativeCallableType? _dartFuncListenerTrampoline;

''');
    }

    // Call method.
    s.write('  ${returnType.getDartType(w)} call($paramsDartType) =>');
    final callMethodArgs = params
        .map((p) =>
            p.type.convertDartTypeToFfiDartType(w, p.name, objCRetain: false))
        .join(', ');
    final callMethodInvocation = '''
pointer.ref.invoke.cast<$natTrampFnType>().asFunction<$trampFuncFfiDartType>()(
    pointer, $callMethodArgs)''';
    s.write(returnType.convertFfiDartTypeToDartType(w, callMethodInvocation,
        objCRetain: false));
    s.write(';\n');

    s.write('}\n');
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
    final fnName = _wrapListenerBlock!.originalName;
    final blockTypedef = w.objCLevelUniqueNamer.makeUnique('ListenerBlock');

    final s = StringBuffer();
    s.write('''

typedef ${getNativeType(varName: blockTypedef)};
$blockTypedef $fnName($blockTypedef block) {
  $blockTypedef wrapper = [^void(${argsReceived.join(', ')}) {
    block(${retains.join(', ')});
  } copy];
  [block release];
  return wrapper;
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
        parameters: [Parameter(name: 'block', type: this)],
        objCReturnsRetained: true,
        isLeaf: true,
        isInternal: true,
        ffiNativeConfig: const FfiNativeConfig(enabled: true),
      )..addDependencies(dependencies);
    }
  }

  @override
  String getCType(Writer w) => PointerType(objCBlockType).getCType(w);

  @override
  String getDartType(Writer w) => name;

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
  String? generateRetain(String value) => '[$value copy]';

  @override
  String toString() => '($returnType (^)(${argTypes.join(', ')}))';
}
