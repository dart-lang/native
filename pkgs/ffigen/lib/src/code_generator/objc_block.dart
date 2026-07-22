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
import 'utils.dart';
import 'writer.dart';

class ObjCBlock extends BindingType with HasLocalScope {
  final Context context;
  final Type returnType;
  final List<Parameter> params;
  final bool returnsRetained;
  ObjCBlockWrapperFuncs? _blockWrappers;
  ObjCProtocolMethodTrampoline? protocolTrampoline;
  ObjCInterface? _argClass;

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
      final libraryId = context.objCBuiltInFunctions.libraryId;
      final sigHash = _getBlockSigHash(returnType, params, returnsRetained);
      _argClass = ObjCInterface.forBlockArgs(
        context,
        '_BlockArgs_$sigHash',
        '_${libraryId}_BlockArgs_${_blockWrappers!.idHash}',
        params,
      );
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

  // Create a fake USR code for the block. This code is used to dedupe blocks
  // with the same signature. Not intended to be human readable.
  static String _getBlockUsr(
    Type returnType,
    List<Parameter> params,
    bool returnsRetained,
  ) => [
    '${strings.synthUsrChar} objcBlock:',
    '${returnType.cacheKey()} ${returnsRetained ? 'R' : ''}',
    for (final param in params)
      '${param.type.cacheKey()} ${param.objCConsumed ? 'C' : ''}',
  ].join(' ');

  // Similar to _getBlockUsr, but not 100% garunteed to be unique, since it
  // depends on stringified types. The trade off is that this hash is
  // deterministic, whereas _getBlockUsr varies between runs.
  static String _getBlockSigHash(
    Type returnType,
    List<Parameter> params,
    bool returnsRetained,
  ) => fnvHash32(
    [
      '$returnType ${returnsRetained ? 'R' : ''}',
      for (final param in params)
        '${param.type} ${param.objCConsumed ? 'C' : ''}',
    ].join(','),
  ).toRadixString(36);

  bool get hasListener {
    if (returnType != voidType) return false;
    for (final p in params) {
      final t = p.type.typealiasType;

      // Arrays are not compatible with BlockArgs object. With additional work
      // we could support ConstantArray, but it's not clear how we could
      // support IncompleteArray.
      if (t is ConstantArray || t is IncompleteArray) {
        return false;
      }
    }
    return true;
  }

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
    final objPtr = PointerType(objCObjectType);

    final funcPtrTrampoline = localScope.addPrivate('_fnPtrTrampoline');
    final closureTrampoline = localScope.addPrivate('_closureTrampoline');
    final funcPtrCallable = localScope.addPrivate('_fnPtrCallable');
    final closureCallable = localScope.addPrivate('_closureCallable');

    final newPointerBlock = ObjCBuiltInFunctions.newPointerBlock.gen(context);
    final newClosureBlock = ObjCBuiltInFunctions.newClosureBlock.gen(context);
    final newBlockPort = ObjCBuiltInFunctions.newBlockPort.gen(context);
    final newBlockingBlockPort = ObjCBuiltInFunctions.newBlockingBlockPort.gen(
      context,
    );
    final getBlockClosure = ObjCBuiltInFunctions.getBlockClosure.gen(context);
    final returnFfiDartType = returnType.getFfiDartType(context);
    final voidPtrCType = voidPtr.getCType(context);
    final objPtrCType = objPtr.getCType(context);
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
      final listenerConvertedFnArgs = params
          .map((p) => 'args.${p.name}')
          .join(', ');
      final listenerLocalVars = LocalVariables(localScope);
      final listenerConvFnInvocation = returnType.convertDartTypeToFfiDartType(
        context,
        'fn($listenerConvertedFnArgs)',
        objCRetain: true,
        objCAutorelease: !returnsRetained,
        localVariables: listenerLocalVars,
      );

      final listenerConvFn = params.isEmpty
          ? '($objPtrCType rawArgs) => fn()'
          : '''
($objPtrCType rawArgs) {
  final args = ${_argClass!.name}.fromPointer(
      rawArgs, retain: false, release: false);
  ${listenerLocalVars.generateDeclarations()}
  $listenerConvFnInvocation;
}''';

      final wrapListenerFn = _blockWrappers!.listenerWrapper.name;
      final wrapBlockingFn = _blockWrappers!.blockingWrapper.name;

      s.write('''
  /// Creates a listener block from a Dart function.
  ///
  /// This block can be invoked from any thread, but only supports void
  /// functions, and is not run synchronously. Async functions (ie returning
  /// Future<void>) are not supported.
  ///
  /// If `keepIsolateAlive` is true, this block will keep this isolate alive
  /// until it is garbage collected by both Dart and ObjC.
  static $blockType listener(${_helper.dartType} fn,
          {bool keepIsolateAlive = true}) {
    return $blockType(
        $newBlockPort($wrapListenerFn, $listenerConvFn, keepIsolateAlive),
        retain: false, release: true);
  }

  /// Creates a blocking block from a Dart function.
  ///
  /// This callback can be invoked from any native thread, and will block the
  /// caller until the callback is handled by the Dart isolate that created
  /// the block. Async functions (ie returning Future<void>) are not supported.
  ///
  /// If `keepIsolateAlive` is true, this block will keep this isolate alive
  /// until it is garbage collected by both Dart and ObjC. If the owner isolate
  /// has shut down, and the block is invoked by native code, it may block
  /// indefinitely, or have other undefined behavior.
  static $blockType blocking(${_helper.dartType} fn,
          {bool keepIsolateAlive = true}) {
    return $blockType($newBlockingBlockPort(
            $wrapBlockingFn, $listenerConvFn, keepIsolateAlive),
        retain: false, release: true);
  }
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
    final argDecls = <String>[];
    final argAssigns = <String>[];
    final retains = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final argName = 'arg$i';
      final type = param.type.typealiasType;
      final isBlock = type is ObjCBlock;
      final isObj =
          type is ObjCObjectPointer ||
          type is ObjCInterface ||
          type is ObjCNullable;
      final argWithType = param.getNativeType(
        context,
        varName: argName,
        withAttr: false,
      );
      argsReceived.add(argWithType);
      final propAttr = isBlock ? '(copy) ' : (isObj ? '(strong) ' : '');
      argDecls.add('@property $propAttr$argWithType;');
      argAssigns.add('args.$argName = $argName;');
      retains.add(param.type.generateRetain(argName) ?? argName);
    }

    final argStr = argsReceived.join(', ');
    final declArgStr = argStr.isEmpty ? 'void' : argStr;
    final blockingArgStr = [
      _waiterParam.getNativeType(context, varName: _waiterParam.name),
      ...argsReceived,
    ].join(', ');
    final argDeclStr = argDecls.join('\n');
    final argAssignStr = argAssigns.join('\n      ');

    final argClassName = _argClass!.originalName;
    final listenerWrapper = _blockWrappers!.listenerWrapper.name;
    final blockingWrapper = _blockWrappers!.blockingWrapper.name;
    final listenerName = Namer.cSafeName(
      context.rootObjCScope.addPrivate('_ListenerTrampoline'),
    );
    final blockingName = Namer.cSafeName(
      context.rootObjCScope.addPrivate('_BlockingTrampoline'),
    );

    return '''

__attribute__((visibility("default")))
@interface $argClassName : NSObject
@property (copy) id block;
$argDeclStr
@end
@implementation $argClassName
@end

typedef ${returnType.getNativeType(context)} (^$listenerName)($declArgStr);
__attribute__((visibility("default"))) __attribute__((used))
$listenerName $listenerWrapper(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak $listenerName weakSelfBlock = nil;
  $listenerName strongSelfBlock = [^void($argStr) {
    @autoreleasepool {
      $argClassName* args = [[$argClassName alloc] init];
      args.block = weakSelfBlock;
      $argAssignStr
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef ${returnType.getNativeType(context)} (^$blockingName)($blockingArgStr);
__attribute__((visibility("default"))) __attribute__((used))
$listenerName $blockingWrapper(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, $listenerName, ^void($argStr), {
    @autoreleasepool {
      $argClassName* args = [[$argClassName alloc] init];
      args.block = weakSelfBlock;
      $argAssignStr
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      $argClassName* args = [[$argClassName alloc] init];
      args.block = weakSelfBlock;
      $argAssignStr
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}
''';
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
    visitor.visit(_argClass);
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
