// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../header_parser/data.dart' show bindingsIndex;
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'writer.dart';

class ObjCBlock extends BindingType {
  final ObjCBuiltInFunctions builtInFunctions;
  final Type returnType;
  final List<Parameter> params;
  final bool returnsRetained;
  ObjCBlockWrapperFuncs? _blockWrappers;

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
  }) : super(originalName: name) {
    if (hasListener) {
      _blockWrappers = builtInFunctions.getBlockTrampolines(this);
    }
  }

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

    final voidPtr = PointerType(voidType);
    final blockPtr = PointerType(objCBlockType);
    final objectPtr = PointerType(objCObjectType);
    final func = _FnHelper(w, returnType, params);

    final blockingFunc = _FnHelper(w, returnType, [
      Parameter(type: voidPtr, name: 'waiter', objCConsumed: false),
      ...params,
    ]);

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
    final blockingTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_blockingTrampoline');
    final blockingCallable =
        w.topLevelUniqueNamer.makeUnique('_${name}_blockingCallable');
    final callExtension =
        w.topLevelUniqueNamer.makeUnique('${name}_CallExtension');

    final newPointerBlock = ObjCBuiltInFunctions.newPointerBlock.gen(w);
    final newClosureBlock = ObjCBuiltInFunctions.newClosureBlock.gen(w);
    final getBlockClosure = ObjCBuiltInFunctions.getBlockClosure.gen(w);
    final releaseFn = ObjCBuiltInFunctions.objectRelease.gen(w);
    final wrapBlockingBlockFn = ObjCBuiltInFunctions.wrapBlockingBlock.gen(w);
    final signalWaiterFn = ObjCBuiltInFunctions.signalWaiter.gen(w);
    final returnFfiDartType = returnType.getFfiDartType(w);
    final voidPtrCType = voidPtr.getCType(w);
    final objectCType = objectPtr.getCType(w);
    final blockCType = blockPtr.getCType(w);
    final blockType = _blockType(w);
    final defaultValue = returnType.getDefaultValue(w);
    final exceptionalReturn = defaultValue == null ? '' : ', $defaultValue';

    // Write the function pointer based trampoline function.
    s.write('''
$returnFfiDartType $funcPtrTrampoline(
    $blockCType block, ${func.paramsFfiDartType}) =>
        block.ref.target.cast<${func.natFnFfiDartType}>()
            .asFunction<${func.ffiDartType}>()(${func.paramsNameOnly});
$voidPtrCType $funcPtrCallable = ${w.ffiLibraryPrefix}.Pointer.fromFunction<
    ${func.trampCType}>($funcPtrTrampoline $exceptionalReturn).cast();
''');

    // Write the closure based trampoline function.
    s.write('''
$returnFfiDartType $closureTrampoline(
    $blockCType block, ${func.paramsFfiDartType}) =>
    ($getBlockClosure(block) as ${func.ffiDartType})(${func.paramsNameOnly});
$voidPtrCType $closureCallable = ${w.ffiLibraryPrefix}.Pointer.fromFunction<
    ${func.trampCType}>($closureTrampoline $exceptionalReturn).cast();
''');

    if (hasListener) {
      // Write the listener trampoline function.
      final nsCondition = s.write('''
$returnFfiDartType $listenerTrampoline(
    $blockCType block, ${func.paramsFfiDartType}) {
  ($getBlockClosure(block) as ${func.ffiDartType})(${func.paramsNameOnly});
  $releaseFn(block.cast());
}
${func.trampNatCallType} $listenerCallable = ${func.trampNatCallType}.listener(
    $listenerTrampoline $exceptionalReturn)..keepIsolateAlive = false;
Future<$returnFfiDartType> $blockingTrampoline(
    $blockCType block, ${blockingFunc.paramsFfiDartType}) async {
  await ($getBlockClosure(block) as ${func.asyncFfiDartType})(
      ${func.paramsNameOnly});
  $signalWaiterFn(waiter);
  $releaseFn(block.cast());
}
${blockingFunc.trampNatCallType} $blockingCallable =
    ${blockingFunc.trampNatCallType}.listener(
        $blockingTrampoline $exceptionalReturn)..keepIsolateAlive = false;
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
    final convFn = '(${func.paramsFfiDartType}) => $convFnInvocation';

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
  static $blockType fromFunctionPointer(${func.natFnPtrCType} ptr) =>
      $blockType($newPointerBlock($funcPtrCallable, ptr.cast()),
          retain: false, release: true);

  /// Creates a block from a Dart function.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  static $blockType fromFunction(${func.dartType} fn) =>
      $blockType($newClosureBlock($closureCallable, $convFn),
          retain: false, release: true);
''');

    // Listener block constructor is only available for void blocks.
    if (hasListener) {
      // This snippet is the same as the convFn above, except that the params
      // don't need to be retained because they've already been retained by
      // _blockWrappers.listenerWrapper.
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
          '(${func.paramsFfiDartType}) => $listenerConvFnInvocation';
      final wrapListenerFn = _blockWrappers!.listenerWrapper.name;
      final wrapBlockingFn = _blockWrappers!.blockingWrapper.name;

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
  static $blockType listener(${func.dartType} fn) {
    final raw = $newClosureBlock(
        $listenerCallable.nativeFunction.cast(), $listenerConvFn);
    final wrapper = $wrapListenerFn(raw);
    $releaseFn(raw.cast());
    return $blockType(wrapper, retain: false, release: true);
  }

  static $blockType blocking(
      ${func.dartType} fn, {Duration timeout = const Duration(seconds: 1)}) {
    final raw = $newClosureBlock(
        $blockingCallable.nativeFunction.cast(), $listenerConvFn);
    final wrapper = $wrapBlockingBlockFn($wrapBlockingFn, raw, timeout);
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
  ${returnType.getDartType(w)} call(${func.paramsDartType}) =>''');
    final callMethodArgs = params
        .map((p) => p.type.convertDartTypeToFfiDartType(
              w,
              p.name,
              objCRetain: p.objCConsumed,
              objCAutorelease: false,
            ))
        .join(', ');
    final callMethodInvocation = '''
ref.pointer.ref.invoke.cast<${func.trampNatFnCType}>()
  .asFunction<${func.trampFfiDartType}>()(
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
    if (_blockWrappers?.objCBindingsGenerated ?? true) return null;
    _blockWrappers!.objCBindingsGenerated = true;

    final argsReceived = <String>[];
    final retains = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final argName = 'arg$i';
      argsReceived.add(param.getNativeType(varName: argName));
      retains.add(param.type.generateRetain(argName) ?? argName);
    }
    final waiterParam = Parameter(
        name: 'waiter', type: PointerType(voidType), objCConsumed: false);
    final blockingRetains = [waiterParam.name, ...retains];

    final argStr = argsReceived.join(', ');
    final blockingArgStr = [
      waiterParam.getNativeType(varName: waiterParam.name),
      ...argsReceived,
    ].join(', ');

    final listenerWrapper = _blockWrappers!.listenerWrapper.name;
    final blockingWrapper = _blockWrappers!.blockingWrapper.name;
    final listenerName =
        w.objCLevelUniqueNamer.makeUnique('_ListenerTrampoline');
    final blockingName =
        w.objCLevelUniqueNamer.makeUnique('_BlockingTrampoline');

    final s = StringBuffer();
    s.write('''

typedef ${returnType.getNativeType()} (^$listenerName)($argStr);
__attribute__((visibility("default"))) __attribute__((used))
$listenerName $listenerWrapper($listenerName block) NS_RETURNS_RETAINED {
  return ^void($argStr) {
    ${generateRetain('block')};
    block(${retains.join(', ')});
  };
}

typedef ${returnType.getNativeType()} (^$blockingName)($blockingArgStr);
__attribute__((visibility("default"))) __attribute__((used))
$listenerName $blockingWrapper(
    $blockingName block, double timeoutSeconds, void* (*newWaiter)(),
    void (*awaitWaiter)(void*, double)) NS_RETURNS_RETAINED {
  return ^void($argStr) {
    void* waiter = newWaiter();
    ${generateRetain('block')};
    block(${blockingRetains.join(', ')});
    awaitWaiter(waiter, timeoutSeconds);
  };
}
''');
    return BindingString(
        type: BindingStringType.objcBlock, string: s.toString());
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
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(returnType);
    visitor.visitAll(params);
    visitor.visit(_blockWrappers);
  }

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    if (other is ObjCBlock) {
      return Type.isSupertypeOfVariance(
        covariantLeft: [returnType],
        covariantRight: [other.returnType],
        contravariantLeft: params.map((p) => p.type).toList(),
        contravariantRight: other.params.map((p) => p.type).toList(),
      );
    }
    return false;
  }
}

class _FnHelper {
  late final NativeFunc natFnType;
  late final String natFnFfiDartType;
  late final String natFnPtrCType;
  late final String dartType;
  late final String ffiDartType;
  late final String asyncFfiDartType;
  late final String trampCType;
  late final String trampFfiDartType;
  late final String trampNatCallType;
  late final String trampNatFnCType;
  late final String paramsNameOnly;
  late final String paramsFfiDartType;
  late final String paramsDartType;

  _FnHelper(Writer w, Type returnType, List<Parameter> params) {
    final fnType = FunctionType(returnType: returnType, parameters: params);
    natFnType = NativeFunc(fnType);
    natFnFfiDartType = natFnType.getFfiDartType(w);
    natFnPtrCType = PointerType(natFnType).getCType(w);
    dartType = fnType.getDartType(w, writeArgumentNames: false);
    ffiDartType = fnType.getFfiDartType(w, writeArgumentNames: false);

    final asyncFnType =
        FunctionType(returnType: FutureOrType(returnType), parameters: params);
    asyncFfiDartType = asyncFnType.getFfiDartType(w, writeArgumentNames: false);

    final trampFnType = FunctionType(
      returnType: returnType,
      parameters: [
        Parameter(
            type: PointerType(objCBlockType),
            name: 'block',
            objCConsumed: false),
        ...params,
      ],
    );
    trampCType = trampFnType.getCType(w, writeArgumentNames: false);
    trampFfiDartType = trampFnType.getFfiDartType(w, writeArgumentNames: false);
    trampNatCallType = '${w.ffiLibraryPrefix}.NativeCallable<${trampCType}>';
    trampNatFnCType = NativeFunc(trampFnType).getCType(w);

    paramsNameOnly = params.map((p) => p.name).join(', ');
    paramsFfiDartType =
        params.map((p) => '${p.type.getFfiDartType(w)} ${p.name}').join(', ');
    paramsDartType =
        params.map((p) => '${p.type.getDartType(w)} ${p.name}').join(', ');
  }
}
