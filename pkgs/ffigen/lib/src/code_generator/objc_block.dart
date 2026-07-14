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

  bool get hasListener {
    if (returnType != voidType) return false;
    for (final param in params) {
      final t = param.type.typealiasType;
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
    final cSafeName = fnvHash32(name.replaceAll('\$', '_')).toRadixString(36);
    final libraryId = w.context.objCBuiltInFunctions.libraryId;
    final blockArgsName = '_${libraryId}_BlockArgs_$cSafeName';
    final blockingBlockArgsName =
        '_${libraryId}_BlockArgs_${cSafeName}_blocking';

    final context = w.context;
    final voidPtr = PointerType(voidType);
    final blockPtr = PointerType(objCBlockType);

    final funcPtrTrampoline = localScope.addPrivate('_fnPtrTrampoline');
    final closureTrampoline = localScope.addPrivate('_closureTrampoline');
    final funcPtrCallable = localScope.addPrivate('_fnPtrCallable');
    final closureCallable = localScope.addPrivate('_closureCallable');
    final blockingTrampoline = localScope.addPrivate('_blockingTrampoline');
    final blockingCallable = localScope.addPrivate('_blockingCallable');

    final newPointerBlock = ObjCBuiltInFunctions.newPointerBlock.gen(context);
    final newClosureBlock = ObjCBuiltInFunctions.newClosureBlock.gen(context);
    final getBlockClosure = ObjCBuiltInFunctions.getBlockClosure.gen(context);
    final returnFfiDartType = returnType.getFfiDartType(context);
    final voidPtrCType = voidPtr.getCType(context);
    final blockCType = blockPtr.getCType(context);
    final blockType = _blockType(context);
    final defaultValue = returnType.getDefaultValue(context);
    final exceptionalReturn = defaultValue == null ? '' : ', $defaultValue';
    final ffiPrefix = w.context.libs.prefix(ffiImport);
    final paramsNameOnly = _helper.paramsNameOnly;
    final objCObjectImpl = objCObjectType.getFfiDartType(context);

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
          .map(
            (p) => p.type.convertFfiDartTypeToDartType(
              context,
              p.name,
              objCRetain: !p.objCConsumed,
            ),
          )
          .join(', ');
      final listenerLocalVars = LocalVariables(localScope);
      final listenerConvFnInvocation = returnType.convertDartTypeToFfiDartType(
        context,
        'fn($listenerConvertedFnArgs)',
        objCRetain: true,
        objCAutorelease: !returnsRetained,
        localVariables: listenerLocalVars,
      );
      final listenerConvFn =
          '''
(${_helper.paramsFfiDartType}) {
  ${listenerLocalVars.generateDeclarations()}
  return $listenerConvFnInvocation;
}''';

      final portListenerConvertedFnArgs = List.generate(
        params.length,
        (i) => _convertedArgVal(i, blockArgsName, context),
      );
      final portBlockingConvertedFnArgs = List.generate(
        params.length,
        (i) => _convertedArgVal(i, blockingBlockArgsName, context),
      );

      final newPortBlock = ObjCBuiltInFunctions.newPortBlock.gen(context);

      s.write('''
  /// Creates a listener block from a Dart function.
  ///
  /// This is based on RawReceivePort, and has the same capabilities and
  /// limitations. This block can be invoked from any thread, but only supports
  /// void functions, and is not run synchronously.
  ///
  /// If `keepIsolateAlive` is true, this block will keep this isolate alive
  /// until it is garbage collected by both Dart and ObjC.
  static $ffiPrefix.Pointer<objc.ObjCBlockImpl> _createListenerPortBlock(
      ${_helper.dartType} fn, bool keepIsolateAlive) {
    return $newPortBlock(
      $ffiPrefix.nullptr,
      (int msg) {
        try {
          ${params.isEmpty ? '' : 'final rawMsg = $ffiPrefix.Pointer.fromAddress(msg).cast<$objCObjectImpl>();'}
          ${params.isEmpty ? '' : 'final args = objc.NSObject.fromPointer(rawMsg, retain: false, release: false);'}
          ${params.isEmpty ? '' : 'final raw = args.ref.pointer;'}
          fn(${portListenerConvertedFnArgs.join(', ')});
        } catch (_) {}
      },
      keepIsolateAlive: keepIsolateAlive,
    );
  }

  /// Creates a listener block from a Dart function.
  ///
  /// This is based on RawReceivePort, and has the same capabilities and
  /// limitations. This block can be invoked from any thread, but only supports
  /// void functions, and is not run synchronously.
  ///
  /// If `keepIsolateAlive` is true, this block will keep this isolate alive
  /// until it is garbage collected by both Dart and ObjC.
  static $blockType listener(${_helper.dartType} fn,
          {bool keepIsolateAlive = true}) {
    final rawDummy = _createListenerPortBlock(fn, keepIsolateAlive);
    final raw = _${libraryId}_${cSafeName}_wrapPortBlock(
      rawDummy.cast(),
      objc.getPortBlockId(rawDummy),
      objc.objCContext.cast(),
    );
    return $blockType(raw, retain: false, release: true);
  }

  static $ffiPrefix.Pointer<objc.ObjCBlockImpl> _createBlockingPortBlock(
      ${_helper.dartType} fn, bool keepIsolateAlive) {
    return $newPortBlock(
      $ffiPrefix.nullptr,
      (int msg) {
        try {
          ${params.isEmpty ? '' : 'final rawMsg = $ffiPrefix.Pointer.fromAddress(msg).cast<$objCObjectImpl>();'}
          ${params.isEmpty ? '' : 'final args = objc.NSObject.fromPointer(rawMsg, retain: false, release: false);'}
          ${params.isEmpty ? '' : 'final raw = args.ref.pointer;'}
          fn(${portBlockingConvertedFnArgs.join(', ')});
        } catch (_) {}
      },
      keepIsolateAlive: keepIsolateAlive,
    );
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
        $listenerConvFn, keepIsolateAlive);
    final rawListener = _createBlockingPortBlock(fn, keepIsolateAlive);
    final wrapper = _${libraryId}_${cSafeName}_wrapPortBlock_blocking(
      raw.cast(),
      rawListener.cast(),
      objc.getPortBlockId(rawListener),
      objc.objCContext.cast(),
    );
    return $blockType(wrapper, retain: false, release: true);
  }

  static $returnFfiDartType $blockingTrampoline(
      $blockCType block, ${_blockingHelper.paramsFfiDartType}) =>
      ($getBlockClosure(block) as ${_helper.ffiDartType})($paramsNameOnly);
  static ${_blockingHelper.trampNatCallType} $blockingCallable =
      ${_blockingHelper.trampNatCallType}.isolateLocal(
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

    if (hasListener) {
      s.write('''
@$ffiPrefix.Native<
    $ffiPrefix.Pointer<$objCObjectImpl> Function(
      $ffiPrefix.Pointer<$objCObjectImpl>,
    )>(symbol: '${blockArgsName}_getBlock', isLeaf: true)
external $ffiPrefix.Pointer<$objCObjectImpl> ${blockArgsName}_getBlock(
  $ffiPrefix.Pointer<$objCObjectImpl> peer,
);
''');

      for (var i = 0; i < params.length; ++i) {
        final param = params[i];
        final paramType = param.type.typealiasType;
        final isObjCObject =
            paramType is ObjCInterface ||
            paramType is ObjCObjectPointer ||
            paramType is ObjCBlock ||
            paramType is ObjCBlockPointer;

        final String ffiCallType;
        final String ffiDartType;

        if (isObjCObject) {
          ffiCallType = '$ffiPrefix.Pointer<$objCObjectImpl>';
          ffiDartType = '$ffiPrefix.Pointer<$objCObjectImpl>';
        } else {
          ffiCallType = param.type.getCType(context);
          ffiDartType = param.type.getFfiDartType(context);
        }

        final nameSuffix = (isObjCObject && param.objCConsumed)
            ? 'takeArg$i'
            : 'getArg$i';
        s.write('''
@$ffiPrefix.Native<
    $ffiCallType Function(
      $ffiPrefix.Pointer<$objCObjectImpl>,
    )>(symbol: '${blockArgsName}_$nameSuffix', isLeaf: true)
external $ffiDartType ${blockArgsName}_$nameSuffix(
  $ffiPrefix.Pointer<$objCObjectImpl> peer,
);
''');
      }

      s.write('''
@$ffiPrefix.Native<
    $blockCType Function(
      $blockCType,
      $ffiPrefix.Int64,
      $ffiPrefix.Pointer<$ffiPrefix.Void>,
    )>(symbol: '_${libraryId}_${cSafeName}_wrapPortBlock')
external $blockCType _${libraryId}_${cSafeName}_wrapPortBlock(
  $blockCType block,
  int portId,
  $ffiPrefix.Pointer<$ffiPrefix.Void> ctx,
);
''');
    }

    s.write('''
@$ffiPrefix.Native<
    $ffiPrefix.Void Function(
      $ffiPrefix.Pointer<$ffiPrefix.Void>,
      $ffiPrefix.Pointer<$ffiPrefix.Void>,
    )>(symbol: '${blockingBlockArgsName}_free', isLeaf: true)
external void ${blockingBlockArgsName}_free(
  $ffiPrefix.Pointer<$ffiPrefix.Void> isolateCallbackData,
  $ffiPrefix.Pointer<$ffiPrefix.Void> peer,
);

@$ffiPrefix.Native<
    $ffiPrefix.Pointer<$objCObjectImpl> Function(
      $ffiPrefix.Pointer<$objCObjectImpl>,
    )>(symbol: '${blockingBlockArgsName}_getBlock', isLeaf: true)
external $ffiPrefix.Pointer<$objCObjectImpl> ${blockingBlockArgsName}_getBlock(
  $ffiPrefix.Pointer<$objCObjectImpl> peer,
);

''');

    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final paramType = param.type.typealiasType;
      final isObjCObject =
          paramType is ObjCInterface ||
          paramType is ObjCObjectPointer ||
          paramType is ObjCBlock ||
          paramType is ObjCBlockPointer;

      final String ffiCallType;
      final String ffiDartType;

      if (isObjCObject) {
        ffiCallType = '$ffiPrefix.Pointer<$objCObjectImpl>';
        ffiDartType = '$ffiPrefix.Pointer<$objCObjectImpl>';
      } else {
        ffiCallType = param.type.getCType(context);
        ffiDartType = param.type.getFfiDartType(context);
      }

      final nameSuffix = (isObjCObject && param.objCConsumed)
          ? 'takeArg$i'
          : 'getArg$i';
      s.write('''
@$ffiPrefix.Native<
    $ffiCallType Function(
      $ffiPrefix.Pointer<$objCObjectImpl>,
    )>(symbol: '${blockingBlockArgsName}_$nameSuffix', isLeaf: true)
external $ffiDartType ${blockingBlockArgsName}_$nameSuffix(
  $ffiPrefix.Pointer<$objCObjectImpl> peer,
);
''');
    }

    s.write('''
@$ffiPrefix.Native<
    $blockCType Function(
      $blockCType,
      $blockCType,
      $ffiPrefix.Int64,
      $ffiPrefix.Pointer<$ffiPrefix.Void>,
    )>(symbol: '_${libraryId}_${cSafeName}_wrapPortBlock_blocking')
external $blockCType _${libraryId}_${cSafeName}_wrapPortBlock_blocking(
  $blockCType block,
  $blockCType listenerBlock,
  int portId,
  $ffiPrefix.Pointer<$ffiPrefix.Void> ctx,
);
''');

    return BindingString(
      type: BindingStringType.objcBlock,
      string: s.toString(),
    );
  }

  @override
  BindingString? toObjCBindingString(Writer w) {
    final chunks = [
      if (hasListener) _wrapPortBlockBindingString(w),
      if (hasListener) _wrapPortBlockBlockingBindingString(w),
      _protocolTrampolineBindingString(w),
    ].nonNulls;
    if (chunks.isEmpty) return null;
    return BindingString(
      type: BindingStringType.objcBlock,
      string: chunks.join(''),
    );
  }

  String _wrapPortBlockBindingString(Writer w) {
    final context = w.context;
    final cSafeName = fnvHash32(name.replaceAll('\$', '_')).toRadixString(36);
    final libraryId = context.objCBuiltInFunctions.libraryId;
    final blockArgsName = '_${libraryId}_BlockArgs_$cSafeName';

    final argsReceived = <String>[];
    final retains = <String>[];
    final assignments = <String>[];
    final unconsumedReleases = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final argName = 'arg$i';
      argsReceived.add(param.getNativeType(context, varName: argName));
      retains.add(argName);

      final paramType = param.type.typealiasType;
      final isBlock = paramType is ObjCBlock || paramType is ObjCBlockPointer;
      final isObjCObject =
          isBlock ||
          paramType is ObjCInterface ||
          paramType is ObjCObjectPointer;

      if (isBlock) {
        assignments.add(
          'args->$argName = (__bridge void*)'
          'objc_retainBlock($argName);',
        );
        unconsumedReleases.add(
          'if (args->$argName != NULL) {\n'
          '      id relObj = (__bridge_transfer id)args->$argName;\n'
          '    }',
        );
      } else if (isObjCObject) {
        assignments.add('args->$argName = (__bridge_retained void*)$argName;');
        unconsumedReleases.add(
          'if (args->$argName != NULL) {\n'
          '      id relObj = (__bridge_transfer id)args->$argName;\n'
          '    }',
        );
      } else {
        assignments.add('args->$argName = $argName;');
      }
    }

    final argStr = argsReceived.join(', ');
    final declArgStr = argStr.isEmpty ? 'void' : argStr;
    final blockType = Namer.cSafeName(
      context.rootObjCScope.addPrivate('_ListenerTrampoline'),
    );

    final argsFields = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final paramType = param.type.typealiasType;
      final isObjCObject =
          paramType is ObjCInterface ||
          paramType is ObjCObjectPointer ||
          paramType is ObjCBlock ||
          paramType is ObjCBlockPointer;

      if (isObjCObject) {
        argsFields.add('  void* arg$i;');
      } else {
        argsFields.add('  ${param.type.getNativeType(context)} arg$i;');
      }
    }

    final getters = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final paramType = param.type.typealiasType;
      final isObjCObject =
          paramType is ObjCInterface ||
          paramType is ObjCObjectPointer ||
          paramType is ObjCBlock ||
          paramType is ObjCBlockPointer;

      if (isObjCObject) {
        final nameSuffix = param.objCConsumed ? 'takeArg$i' : 'getArg$i';
        getters.add('''
__attribute__((visibility("default"))) __attribute__((used))
void* ${blockArgsName}_$nameSuffix(void* peer) {
  void* val = ((__bridge $blockArgsName*)peer)->arg$i;
  ((__bridge $blockArgsName*)peer)->arg$i = NULL;
  return val;
}
''');
      } else {
        final declType = param.type.getNativeType(context);
        getters.add('''
__attribute__((visibility("default"))) __attribute__((used))
$declType ${blockArgsName}_getArg$i(void* peer) {
  return ((__bridge $blockArgsName*)peer)->arg$i;
}
''');
      }
    }

    return '''
@interface $blockArgsName : NSObject {
  @public
  id block;
  void* context;
${argsFields.join('\n')}
}
@end

@implementation $blockArgsName
@end

${getters.join('\n')}

void ${blockArgsName}_free(void* peer) {
  @autoreleasepool {
    $blockArgsName* args = (__bridge $blockArgsName*)peer;
    ${unconsumedReleases.join('\n    ')}
    id argsObj = (__bridge_transfer id)peer;
  }
}

void ${blockArgsName}_finalize(void* isolate_callback_data, void* peer) {
  $blockArgsName* args = (__bridge $blockArgsName*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(${blockArgsName}_free, peer);
}

typedef ${returnType.getNativeType(context)} (^$blockType)($declArgStr);

__attribute__((visibility("default"))) __attribute__((used))
void* _${libraryId}_${cSafeName}_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void($argStr) {
    $blockArgsName* args = [[$blockArgsName alloc] init];
    args->block = block;
    args->context = context;
    ${assignments.join('\n    ')}
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, ${blockArgsName}_finalize);
  } copy]);
}
''';
  }

  String _wrapPortBlockBlockingBindingString(Writer w) {
    final context = w.context;
    final cSafeName = fnvHash32(name.replaceAll('\$', '_')).toRadixString(36);
    final libraryId = context.objCBuiltInFunctions.libraryId;
    final blockArgsName = '_${libraryId}_BlockArgs_${cSafeName}_blocking';

    final argsReceived = <String>[];
    final retains = <String>[];
    final assignments = <String>[];
    final unconsumedReleases = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final argName = 'arg$i';
      argsReceived.add(param.getNativeType(context, varName: argName));
      retains.add(argName);

      final paramType = param.type.typealiasType;
      final isBlock = paramType is ObjCBlock || paramType is ObjCBlockPointer;
      final isObjCObject =
          isBlock ||
          paramType is ObjCInterface ||
          paramType is ObjCObjectPointer;

      if (isBlock) {
        assignments.add(
          'args->$argName = (__bridge void*)'
          'objc_retainBlock($argName);',
        );
        unconsumedReleases.add(
          'if (args->$argName != NULL) {\n'
          '      id relObj = (__bridge_transfer id)args->$argName;\n'
          '    }',
        );
      } else if (isObjCObject) {
        assignments.add('args->$argName = (__bridge_retained void*)$argName;');
        unconsumedReleases.add(
          'if (args->$argName != NULL) {\n'
          '      id relObj = (__bridge_transfer id)args->$argName;\n'
          '    }',
        );
      } else {
        assignments.add('args->$argName = $argName;');
      }
    }

    final argStr = argsReceived.join(', ');
    final blockType = Namer.cSafeName(
      context.rootObjCScope.addPrivate('_BlockingTrampoline'),
    );

    final argsFields = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final paramType = param.type.typealiasType;
      final isObjCObject =
          paramType is ObjCInterface ||
          paramType is ObjCObjectPointer ||
          paramType is ObjCBlock ||
          paramType is ObjCBlockPointer;

      if (isObjCObject) {
        argsFields.add('  void* arg$i;');
      } else {
        argsFields.add('  ${param.type.getNativeType(context)} arg$i;');
      }
    }

    final getters = <String>[];
    for (var i = 0; i < params.length; ++i) {
      final param = params[i];
      final paramType = param.type.typealiasType;
      final isObjCObject =
          paramType is ObjCInterface ||
          paramType is ObjCObjectPointer ||
          paramType is ObjCBlock ||
          paramType is ObjCBlockPointer;

      if (isObjCObject) {
        final nameSuffix = param.objCConsumed ? 'takeArg$i' : 'getArg$i';
        getters.add('''
__attribute__((visibility("default"))) __attribute__((used))
void* ${blockArgsName}_$nameSuffix(void* peer) {
  void* val = ((__bridge $blockArgsName*)peer)->arg$i;
  ((__bridge $blockArgsName*)peer)->arg$i = NULL;
  return val;
}
''');
      } else {
        final declType = param.type.getNativeType(context);
        getters.add('''
__attribute__((visibility("default"))) __attribute__((used))
$declType ${blockArgsName}_getArg$i(void* peer) {
  return ((__bridge $blockArgsName*)peer)->arg$i;
}
''');
      }
    }

    final directArgStr = [
      'void* block',
      if (argStr.isNotEmpty) argStr,
    ].join(', ');
    final directRetains = ['(__bridge void*)block', ...retains].join(', ');

    return '''
@interface $blockArgsName : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
${argsFields.join('\n')}
}
@end

@implementation $blockArgsName
@end

${getters.join('\n')}

__attribute__((visibility("default"))) __attribute__((used))
void ${blockArgsName}_free(void* peer) {
  @autoreleasepool {
    $blockArgsName* args = (__bridge $blockArgsName*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    ${unconsumedReleases.join('\n    ')}
    id argsObj = (__bridge_transfer id)peer;
  }
}

void ${blockArgsName}_finalize(void* isolate_callback_data, void* peer) {
  $blockArgsName* args = (__bridge $blockArgsName*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(${blockArgsName}_free, peer);
}

typedef ${returnType.getNativeType(context)} (^$blockType)($directArgStr);

__attribute__((visibility("default"))) __attribute__((used))
void* _${libraryId}_${cSafeName}_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void($argStr) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      (($blockType)block)($directRetains);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      $blockArgsName* args = [[$blockArgsName alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      ${assignments.join('\n      ')}
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, ${blockArgsName}_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
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

  String _getInnerType(Type type, Context context) {
    final paramType = type.typealiasType;
    if (paramType is ObjCBlock || paramType is ObjCBlockPointer) {
      return objCBlockType.getCType(context);
    }
    return objCObjectType.getCType(context);
  }

  String _rawArgVal(int i, String structName, Context context) {
    final param = params[i];
    final nameSuffix = param.objCConsumed ? 'takeArg$i' : 'getArg$i';
    final paramType = param.type.typealiasType;
    final isObjCObject =
        paramType is ObjCInterface ||
        paramType is ObjCObjectPointer ||
        paramType is ObjCBlock ||
        paramType is ObjCBlockPointer;
    final raw = '${structName}_$nameSuffix(raw)';
    if (isObjCObject) {
      return '$raw.cast<${_getInnerType(param.type, context)}>()';
    }
    return raw;
  }

  String _convertedArgVal(int i, String structName, Context context) {
    final param = params[i];
    return param.type.convertFfiDartTypeToDartType(
      context,
      _rawArgVal(i, structName, context),
      objCRetain: !param.objCConsumed,
    );
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
