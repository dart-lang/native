// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../strings.dart' as strings;
import '../visitor/ast.dart';
import 'binding_string.dart';
import 'local_variables.dart';
import 'scope.dart';
import 'writer.dart';

class ObjCBlock extends BindingType with HasLocalScope {
  final Context context;
  final Type returnType;
  final List<Parameter> params;
  final bool returnsRetained;
  ObjCBlockWrapperFuncs? _blockWrappers;
  ObjCProtocolMethodTrampoline? protocolTrampoline;

  final Parameter _blockParam;
  final Parameter _waiterParam;
  late final _FnHelper _helper;
  late final _FnHelper _blockingHelper;

  factory ObjCBlock(
    Context context, {
    required Type returnType,
    required List<Parameter> params,
    required bool returnsRetained,
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

    final newBlockName = _getBlockName(
      returnType,
      renamedParams.map((a) => a.type),
      reduced: false,
    );
    final oldBlock = context.bindingsIndex.getSeenObjCBlock(usr);
    if (oldBlock != null) {
      if (oldBlock.symbol.oldName != newBlockName) {
        // Block with matching signature, but a different name. This is usually
        // due to type aliases. Replace the name with the reduced name, so that
        // it makes sense as a name for all blocks sharing this signature.
        oldBlock.symbol.oldName = _getBlockName(
          returnType,
          renamedParams.map((a) => a.type),
          reduced: true,
        );
      }
      return oldBlock;
    }

    final block = ObjCBlock._(
      context,
      usr: usr,
      name: newBlockName,
      returnType: returnType,
      params: renamedParams,
      returnsRetained: returnsRetained,
    );
    context.bindingsIndex.addObjCBlockToSeen(usr, block);

    return block;
  }

  ObjCBlock._(
    this.context, {
    required String super.usr,
    required super.name,
    required this.returnType,
    required this.params,
    required this.returnsRetained,
  }) : _waiterParam = Parameter(
         name: 'waiter',
         type: PointerType(voidType),
         objCConsumed: false,
       ),
       _blockParam = Parameter(
         type: PointerType(objCBlockType),
         name: 'block',
         objCConsumed: false,
       ),
       super(originalName: usr) {
    _helper = _FnHelper(context, returnType, params, _blockParam);
    _blockingHelper = _FnHelper(context, returnType, [
      _waiterParam,
      ...params,
    ], _blockParam);
    if (hasListener) {
      _blockWrappers = context.objCBuiltInFunctions.getBlockTrampolines(this);
    }
  }

  void fillProtocolTrampoline() {
    protocolTrampoline ??= context.objCBuiltInFunctions
        .getProtocolMethodTrampoline(this);
  }

  // Generates a human readable name for the block based on the args and return
  // type. These names will be pretty verbose and unweildy, but they're at least
  // sensible and stable. Users can always add their own typedef with a simpler
  // name if necessary.
  static String _getBlockName(
    Type returnType,
    Iterable<Type> argTypes, {
    required bool reduced,
  }) {
    final types = [returnType, ...argTypes].map((t) => _typeName(t, reduced));
    return 'ObjCBlock_${types.join('_')}';
  }

  static String _typeName(Type type, bool reduced) =>
      (reduced ? _reducedType(type) : type).toString().replaceAll(
        _illegalNameChar,
        '',
      );
  static final _illegalNameChar = RegExp(r'[^0-9a-zA-Z]');
  static Type _reducedType(Type type) {
    if (type.baseType != type) return _reducedType(type.baseType);
    if (type.typealiasType != type) return _reducedType(type.typealiasType);
    return type;
  }

  static String _getBlockUsr(
    Type returnType,
    List<Parameter> params,
    bool returnsRetained,
  ) {
    // Create a fake USR code for the block. This code is used to dedupe blocks
    // with the same signature. Not intended to be human readable.
    return [
      '${strings.synthUsrChar} objcBlock:',
      '${returnType.cacheKey()} ${returnsRetained ? 'R' : ''}',
      for (final param in params)
        '${param.type.cacheKey()} ${param.objCConsumed ? 'C' : ''}',
    ].join(' ');
  }

  bool get hasListener => returnType == voidType;

  String _blockType(Context context) {
    final argStr = params
        .map((param) {
          final type = param.type.getObjCBlockSignatureType(context);
          return param.objCConsumed
              ? '${ObjCBuiltInFunctions.consumedType.gen(context)}<$type>'
              : type;
        })
        .join(', ');
    final retType = returnType.getObjCBlockSignatureType(context);
    final retStr = returnsRetained
        ? '${ObjCBuiltInFunctions.retainedType.gen(context)}<$retType>'
        : retType;
    final func = '$retStr Function($argStr)';
    return '${ObjCBuiltInFunctions.blockType.gen(context)}<$func>';
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    final context = w.context;
    final voidPtr = PointerType(voidType);
    final blockPtr = PointerType(objCBlockType);

    final funcPtrTrampoline = localScope.addPrivate('_fnPtrTrampoline');
    final closureTrampoline = localScope.addPrivate('_closureTrampoline');
    final funcPtrCallable = localScope.addPrivate('_fnPtrCallable');
    final closureCallable = localScope.addPrivate('_closureCallable');
    final blockingTrampoline = localScope.addPrivate('_blockingTrampoline');
    final blockingCallable = localScope.addPrivate('_blockingCallable');
    final blockingListenerCallable = localScope.addPrivate(
      '_blockingListenerCallable',
    );

    final newPointerBlock = ObjCBuiltInFunctions.newPointerBlock.gen(context);
    final newClosureBlock = ObjCBuiltInFunctions.newClosureBlock.gen(context);
    final newListenerBlock = ObjCBuiltInFunctions.newListenerBlock.gen(context);
    final getBlockClosure = ObjCBuiltInFunctions.getBlockClosure.gen(context);
    final releaseFn = ObjCBuiltInFunctions.objectRelease.gen(context);
    final objCContext = ObjCBuiltInFunctions.objCContext.gen(context);
    final signalWaiterFn = ObjCBuiltInFunctions.signalWaiter.gen(context);
    final returnFfiDartType = returnType.getFfiDartType(context);
    final voidPtrCType = voidPtr.getCType(context);
    final blockCType = blockPtr.getCType(context);
    final blockType = _blockType(context);
    final defaultValue = returnType.getDefaultValue(context);
    final exceptionalReturn = defaultValue == null ? '' : ', $defaultValue';
    final ffiPrefix = w.context.libs.prefix(ffiImport);
    final paramsNameOnly = _helper.paramsNameOnly;

    // Snippet that converts a Dart typed closure to FfiDart type. This snippet
    // is used below. Note that the closure being converted is called `fn`.
    final convertedFnArgs = params
        .map(
          (p) => p.type.convertFfiDartTypeToDartType(
            context,
            p.name,
            objCRetain: !p.objCConsumed,
          ),
        )
        .join(', ');
    final closureLocalVars = LocalVariables(localScope);
    final convFnInvocation = returnType.convertDartTypeToFfiDartType(
      context,
      'fn($convertedFnArgs)',
      objCRetain: true,
      objCAutorelease: !returnsRetained,
      localVariables: closureLocalVars,
    );
    final convFn =
        '''
(${_helper.paramsFfiDartType}) {
  ${closureLocalVars.generateDeclarations()}
  return $convFnInvocation;
}''';

    // Dart mirror of the C listener invocation struct, emitted once per
    // signature.
    final wrappers = _blockWrappers;
    if (wrappers != null &&
        params.isNotEmpty &&
        !wrappers.dartArgsStructGenerated) {
      wrappers.dartArgsStructGenerated = true;
      final invocationType = ObjCBuiltInFunctions.listenerInvocationType.gen(
        context,
      );
      s.write('''

final class ${wrappers.argsStructName} extends $ffiPrefix.Struct {
  external $invocationType invocation;
''');
      for (var i = 0; i < wrappers.argTypes.length; ++i) {
        final t = wrappers.argTypes[i];
        if (!t.sameFfiDartAndCType) {
          s.write('  @${t.getCType(context)}()\n');
        }
        s.write('  external ${t.getFfiDartType(context)} arg$i;\n');
      }
      s.write('}\n');
    }

    // Write the wrapper class.
    s.write('''

/// Construction methods for `$blockType`.
abstract final class $name {
  /// Returns a block that wraps the given raw block pointer.
  static $blockType fromPointer($blockCType pointer,
      {bool retain = false, bool release = false}) =>
      $blockType(pointer, retain: retain, release: release);

  /// Creates a block from a C function pointer.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  static $blockType fromFunctionPointer(${_helper.natFnPtrCType} ptr) =>
      $blockType($newPointerBlock($funcPtrCallable, ptr.cast()),
          retain: false, release: true);

  /// Creates a block from a Dart function.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  ///
  /// If `keepIsolateAlive` is true, this block will keep this isolate alive
  /// until it is garbage collected by both Dart and ObjC.
  static $blockType fromFunction(${_helper.dartType} fn,
          {bool keepIsolateAlive = true}) =>
      $blockType($newClosureBlock($closureCallable, $convFn, keepIsolateAlive),
          retain: false, release: true);

''');

    // Listener block constructor is only available for void blocks.
    if (hasListener) {
      // Converts the FfiDart args produced by src to Dart types, without
      // retaining them: the ObjC wrapper already retained them.
      String convertedArgs(String Function(int i) src) => [
        for (var i = 0; i < params.length; ++i)
          params[i].type.convertFfiDartTypeToDartType(
            context,
            src(i),
            objCRetain: false,
          ),
      ].join(', ');

      // Same as convFn above, but without retains.
      final blockingLocalVars = LocalVariables(localScope);
      final blockingConvFnInvocation = returnType.convertDartTypeToFfiDartType(
        context,
        'fn(${convertedArgs((i) => params[i].name)})',
        objCRetain: true,
        objCAutorelease: !returnsRetained,
        localVariables: blockingLocalVars,
      );
      final blockingConvFn =
          '''
(${_helper.paramsFfiDartType}) {
  ${blockingLocalVars.generateDeclarations()}
  return $blockingConvFnInvocation;
}''';
      final wrapListenerFn = wrappers!.listenerWrapper.name;
      final wrapBlockingFn = wrappers.blockingWrapper.name;

      // Closure that unpacks the invocation struct posted by the ObjC wrapper
      // and calls fn. package:objective_c frees the struct after it returns.
      final String listenerRawFn;
      if (params.isEmpty) {
        listenerRawFn = '($voidPtrCType _) { fn(); }';
      } else {
        listenerRawFn =
            '''($voidPtrCType invocation) {
      final args = invocation.cast<${wrappers.argsStructName}>().ref;
      fn(${convertedArgs((i) => 'args.arg$i')});
    }''';
      }

      s.write('''
  /// Creates a listener block from a Dart function.
  ///
  /// This block can be invoked from any thread, but only supports void
  /// functions, and is not run synchronously: invocations are delivered
  /// asynchronously to the isolate that created the block. Invocations that
  /// arrive after that isolate has shut down are silently dropped.
  ///
  /// If `keepIsolateAlive` is true, this block will keep this isolate alive
  /// until it is garbage collected by both Dart and ObjC.
  static $blockType listener(${_helper.dartType} fn,
          {bool keepIsolateAlive = true}) {
    final raw = $newListenerBlock($listenerRawFn, keepIsolateAlive);
    final wrapper = $wrapListenerFn(raw, $objCContext);
    $releaseFn(raw.cast());
    return $blockType(wrapper, retain: false, release: true);
  }

  /// Creates a blocking block from a Dart function.
  ///
  /// This callback can be invoked from any native thread, and will block the
  /// caller until the callback is handled by the Dart isolate that created
  /// the block. Async functions are not supported.
  ///
  /// If `keepIsolateAlive` is true, this block will keep this isolate alive
  /// until it is garbage collected by both Dart and ObjC. If the owner isolate
  /// has shut down, and the block is invoked by native code, it may block
  /// indefinitely, or have other undefined behavior.
  static $blockType blocking(${_helper.dartType} fn,
          {bool keepIsolateAlive = true}) {
    final raw = $newClosureBlock($blockingCallable.nativeFunction.cast(),
        $blockingConvFn, keepIsolateAlive);
    final rawListener = $newClosureBlock(
        $blockingListenerCallable.nativeFunction.cast(),
        $blockingConvFn, keepIsolateAlive);
    final wrapper = $wrapBlockingFn(raw, rawListener, $objCContext);
    $releaseFn(raw.cast());
    $releaseFn(rawListener.cast());
    return $blockType(wrapper, retain: false, release: true);
  }

  static $returnFfiDartType $blockingTrampoline(
      $blockCType block, ${_blockingHelper.paramsFfiDartType}) {
    try {
      ($getBlockClosure(block) as ${_helper.ffiDartType})($paramsNameOnly);
    } catch (e) {
    } finally {
      $signalWaiterFn(waiter);
      $releaseFn(block.cast());
    }
  }
  static ${_blockingHelper.trampNatCallType} $blockingCallable =
      ${_blockingHelper.trampNatCallType}.isolateLocal(
          $blockingTrampoline $exceptionalReturn)..keepIsolateAlive = false;
  static ${_blockingHelper.trampNatCallType} $blockingListenerCallable =
      ${_blockingHelper.trampNatCallType}.listener(
          $blockingTrampoline $exceptionalReturn)..keepIsolateAlive = false;
''');
    }
    s.write('''
  static $returnFfiDartType $funcPtrTrampoline(
      $blockCType block, ${_helper.paramsFfiDartType}) =>
          block.ref.target.cast<${_helper.natFnFfiDartType}>()
              .asFunction<${_helper.ffiDartType}>()($paramsNameOnly);
  static $voidPtrCType $funcPtrCallable = $ffiPrefix.Pointer.fromFunction<
      ${_helper.trampCType}>($funcPtrTrampoline $exceptionalReturn).cast();
  static $returnFfiDartType $closureTrampoline(
      $blockCType block, ${_helper.paramsFfiDartType}) =>
      ($getBlockClosure(block) as ${_helper.ffiDartType})($paramsNameOnly);
  static $voidPtrCType $closureCallable = $ffiPrefix.Pointer.fromFunction<
      ${_helper.trampCType}>($closureTrampoline $exceptionalReturn).cast();
}

''');

    // Call operator extension method.
    s.write('''
/// Call operator for `$blockType`.
extension $name\$CallExtension on $blockType {
  ${returnType.getDartType(context)} call(${_helper.paramsDartType})''');

    final callLocalVars = LocalVariables(localScope);
    final callMethodArgs = params
        .map(
          (p) => p.type.convertDartTypeToFfiDartType(
            context,
            p.name,
            objCRetain: p.objCConsumed,
            objCAutorelease: false,
            localVariables: callLocalVars,
          ),
        )
        .join(', ');

    s.write(''' {
    ${callLocalVars.generateDeclarations()}
    return ''');

    final callMethodInvocation =
        '''
ref.pointer.ref.invoke.cast<${_helper.trampNatFnCType}>()
  .asFunction<${_helper.trampFfiDartType}>()(
    ref.pointer, $callMethodArgs)''';
    s.write(
      returnType.convertFfiDartTypeToDartType(
        context,
        callMethodInvocation,
        objCRetain: !returnsRetained,
      ),
    );
    s.write(';\n');
    s.write('  }\n');

    s.write('}\n\n');
    return BindingString(
      type: BindingStringType.objcBlock,
      string: s.toString(),
    );
  }

  @override
  BindingString? toObjCBindingString(Writer w) {
    final chunks = [
      _blockWrappersBindingString(w),
      _protocolTrampolineBindingString(w),
    ].nonNulls;
    if (chunks.isEmpty) return null;
    return BindingString(
      type: BindingStringType.objcBlock,
      string: chunks.join(''),
    );
  }

  String? _blockWrappersBindingString(Writer w) {
    if (_blockWrappers?.objCBindingsGenerated ?? true) return null;
    _blockWrappers!.objCBindingsGenerated = true;

    final argsReceived = <String>[];
    final retains = <String>[];
    // Listener invocation struct fields, pack statements, and dispose
    // statements. Retained args (ObjC objects and blocks) are stored as
    // void* at +1.
    final argsStructFields = <String>[];
    final argsPacks = <String>[];
    final argsDisposes = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final argName = 'arg$i';
      final nativeType = param.getNativeType(context, varName: argName);
      argsReceived.add(nativeType);
      final retain = param.type.generateRetain(argName);
      retains.add(retain ?? argName);
      if (retain != null) {
        argsStructFields.add('void *$argName;');
        // For consumed params, ARC releases the incoming +1 at the end of the
        // wrapper body (ns_consumed), so __bridge_retained takes an extra
        // retain to keep the packed reference at +1.
        final bridge = param.objCConsumed ? '__bridge_retained' : '__bridge';
        argsPacks.add('args->$argName = ($bridge void*)($retain);');
        argsDisposes.add('(void)(__bridge_transfer id)(args->$argName);');
      } else {
        argsStructFields.add('$nativeType;');
        argsPacks.add('args->$argName = $argName;');
      }
    }
    final blockingRetains = ['nil', ...retains];
    final blockingListenerRetains = [_waiterParam.name, ...retains];

    final argStr = argsReceived.join(', ');
    final declArgStr = argStr.isEmpty ? 'void' : argStr;
    final blockingArgStr = [
      _waiterParam.getNativeType(context, varName: _waiterParam.name),
      ...argsReceived,
    ].join(', ');

    final listenerWrapper = _blockWrappers!.listenerWrapper.name;
    final blockingWrapper = _blockWrappers!.blockingWrapper.name;
    final listenerName = Namer.cSafeName(
      context.rootObjCScope.addPrivate('_ListenerTrampoline'),
    );
    final blockingName = Namer.cSafeName(
      context.rootObjCScope.addPrivate('_BlockingTrampoline'),
    );

    final s = StringBuffer();

    // The listener invocation struct (a DOBJC_ListenerInvocation header
    // followed by the packed args), its dispose function (run only for
    // undelivered invocations), and the pack-and-post wrapper.
    final argsStructName = _blockWrappers!.argsStructName;
    final argsDisposeName = '${argsStructName}_dispose';
    final String makeInvocation;
    var disposePtr = 'NULL';
    if (params.isEmpty) {
      makeInvocation = '''
    DOBJC_ListenerInvocation *invocation =
        (DOBJC_ListenerInvocation *)malloc(sizeof(DOBJC_ListenerInvocation));
    invocation->dispose = NULL;''';
    } else {
      s.write('''

typedef struct {
  DOBJC_ListenerInvocation invocation;
  ${argsStructFields.join('\n  ')}
} $argsStructName;
''');
      if (argsDisposes.isNotEmpty) {
        disposePtr = '&$argsDisposeName';
        s.write('''

static void $argsDisposeName(DOBJC_ListenerInvocation *invocation) {
  $argsStructName *args = ($argsStructName *)invocation;
  ${argsDisposes.join('\n  ')}
}
''');
      }
      makeInvocation =
          '''
    $argsStructName *args = ($argsStructName *)malloc(sizeof($argsStructName));
    args->invocation.dispose = $disposePtr;
    ${argsPacks.join('\n    ')}
    DOBJC_ListenerInvocation *invocation = &args->invocation;''';
    }

    s.write('''

typedef ${returnType.getNativeType(context)} (^$listenerName)($declArgStr);
__attribute__((visibility("default"))) __attribute__((used))
$listenerName $listenerWrapper(
    $listenerName block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void($argStr) {
$makeInvocation
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef ${returnType.getNativeType(context)} (^$blockingName)($blockingArgStr);
__attribute__((visibility("default"))) __attribute__((used))
$listenerName $blockingWrapper(
    $blockingName block, $blockingName listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void($argStr), {
    ${generateRetain('block')};
    block(${blockingRetains.join(', ')});
  }, {
    ${generateRetain('listenerBlock')};
    listenerBlock(${blockingListenerRetains.join(', ')});
  });
}
''');
    return s.toString();
  }

  String? _protocolTrampolineBindingString(Writer w) {
    if (protocolTrampoline?.objCBindingsGenerated ?? true) return null;
    protocolTrampoline!.objCBindingsGenerated = true;

    final argsReceived = <String>[];
    final argsPassed = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final argName = i == 0 ? 'sel' : 'arg$i';
      argsReceived.add(param.getNativeType(context, varName: argName));
      argsPassed.add(argName);
    }

    final ret = returnType.getNativeType(context);
    final argRecv = argsReceived.join(', ');
    final argPass = argsPassed.join(', ');
    final fnName = protocolTrampoline!.func.name;
    final block = Namer.cSafeName(
      context.rootObjCScope.addPrivate('_ProtocolTrampoline'),
    );
    final msgSend = '((id (*)(id, SEL, SEL))objc_msgSend)';
    final getterSel = '@selector(getDOBJCDartProtocolMethodForSelector:)';
    final blkGetter = '(($block)$msgSend(target, $getterSel, sel))';

    return '''

typedef $ret (^$block)($argRecv);
__attribute__((visibility("default"))) __attribute__((used))
$ret $fnName(id target, $argRecv) {
  return $blkGetter($argPass);
}
''';
  }

  @override
  String getCType(Context context) =>
      PointerType(objCBlockType).getCType(context);

  // We return `ObjCBlockBase<T>` here instead of the code genned wrapper, so
  // that the subtyping rules work as expected.
  // See https://github.com/dart-lang/native/issues/1416 for details.
  @override
  String getDartType(Context context) => _blockType(context);

  @override
  String getObjCBlockSignatureType(Context context) => getDartType(context);

  @override
  String getNativeType(Context context, {String varName = ''}) => 'id $varName';

  @override
  bool get sameFfiDartAndCType => true;

  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
    required LocalVariables localVariables,
  }) => ObjCInterface.generateGetId(
    context,
    value,
    objCRetain,
    objCAutorelease,
    localVariables,
  );

  @override
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => ObjCInterface.generateConstructor(name, value, objCRetain);

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
    visitor.visit(protocolTrampoline);
    visitor.visit(ffiImport);
    visitor.visit(objcPkgImport);
    _helper.visitChildren(visitor);
    _blockingHelper.visitChildren(visitor);
  }

  @override
  void visit(Visitation visitation) => visitation.visitObjCBlock(this);

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
  final Context context;
  final FunctionType fnType;
  final FunctionType trampFnType;
  late final NativeFunc natFnType;

  late final String natFnFfiDartType = natFnType.getFfiDartType(context);
  late final String natFnPtrCType = PointerType(natFnType).getCType(context);
  late final String dartType = fnType.getDartType(
    context,
    writeArgumentNames: false,
  );
  late final String ffiDartType = fnType.getFfiDartType(
    context,
    writeArgumentNames: false,
  );

  late final String trampCType = trampFnType.getCType(
    context,
    writeArgumentNames: false,
  );
  late final String trampFfiDartType = trampFnType.getFfiDartType(
    context,
    writeArgumentNames: false,
  );
  late final String trampNatCallType =
      '${context.libs.prefix(ffiImport)}.NativeCallable<$trampCType>';
  late final String trampNatFnCType = NativeFunc(trampFnType).getCType(context);

  late final String paramsNameOnly = fnType.parameters
      .map((p) => p.name)
      .join(', ');
  late final String paramsFfiDartType = fnType.parameters
      .map((p) => '${p.type.getFfiDartType(context)} ${p.name}')
      .join(', ');
  late final String paramsDartType = fnType.parameters
      .map((p) => '${p.type.getDartType(context)} ${p.name}')
      .join(', ');

  _FnHelper(
    this.context,
    Type returnType,
    List<Parameter> params,
    Parameter blockParam,
  ) : fnType = FunctionType(returnType: returnType, parameters: params),
      trampFnType = FunctionType(
        returnType: returnType,
        parameters: [blockParam, ...params],
      ) {
    natFnType = NativeFunc(fnType);
  }

  void visitChildren(Visitor visitor) {
    visitor.visit(fnType);
    visitor.visit(trampFnType);
    visitor.visit(natFnType);
  }
}
