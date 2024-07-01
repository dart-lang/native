//
//  Generated code. Do not modify.
//  source: usages_shared.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Metadata extends $pb.GeneratedMessage {
  factory Metadata({
    $core.String? comment,
    $core.String? version,
  }) {
    final $result = create();
    if (comment != null) {
      $result.comment = comment;
    }
    if (version != null) {
      $result.version = version;
    }
    return $result;
  }
  Metadata._() : super();
  factory Metadata.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Metadata.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Metadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'comment')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Metadata clone() => Metadata()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Metadata copyWith(void Function(Metadata) updates) =>
      super.copyWith((message) => updates(message as Metadata)) as Metadata;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Metadata create() => Metadata._();
  Metadata createEmptyInstance() => create();
  static $pb.PbList<Metadata> createRepeated() => $pb.PbList<Metadata>();
  @$core.pragma('dart2js:noInline')
  static Metadata getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Metadata>(create);
  static Metadata? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get comment => $_getSZ(0);
  @$pb.TagNumber(1)
  set comment($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasComment() => $_has(0);
  @$pb.TagNumber(1)
  void clearComment() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => clearField(2);
}

class Fields extends $pb.GeneratedMessage {
  factory Fields({
    $core.Iterable<Field>? fields,
  }) {
    final $result = create();
    if (fields != null) {
      $result.fields.addAll(fields);
    }
    return $result;
  }
  Fields._() : super();
  factory Fields.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Fields.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Fields',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..pc<Field>(1, _omitFieldNames ? '' : 'fields', $pb.PbFieldType.PM,
        subBuilder: Field.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Fields clone() => Fields()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Fields copyWith(void Function(Fields) updates) =>
      super.copyWith((message) => updates(message as Fields)) as Fields;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Fields create() => Fields._();
  Fields createEmptyInstance() => create();
  static $pb.PbList<Fields> createRepeated() => $pb.PbList<Fields>();
  @$core.pragma('dart2js:noInline')
  static Fields getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Fields>(create);
  static Fields? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Field> get fields => $_getList(0);
}

class Arguments extends $pb.GeneratedMessage {
  factory Arguments({
    ConstArguments? constArguments,
    NonConstArguments? nonConstArguments,
  }) {
    final $result = create();
    if (constArguments != null) {
      $result.constArguments = constArguments;
    }
    if (nonConstArguments != null) {
      $result.nonConstArguments = nonConstArguments;
    }
    return $result;
  }
  Arguments._() : super();
  factory Arguments.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Arguments.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Arguments',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..aOM<ConstArguments>(1, _omitFieldNames ? '' : 'constArguments',
        subBuilder: ConstArguments.create)
    ..aOM<NonConstArguments>(2, _omitFieldNames ? '' : 'nonConstArguments',
        subBuilder: NonConstArguments.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Arguments clone() => Arguments()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Arguments copyWith(void Function(Arguments) updates) =>
      super.copyWith((message) => updates(message as Arguments)) as Arguments;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Arguments create() => Arguments._();
  Arguments createEmptyInstance() => create();
  static $pb.PbList<Arguments> createRepeated() => $pb.PbList<Arguments>();
  @$core.pragma('dart2js:noInline')
  static Arguments getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Arguments>(create);
  static Arguments? _defaultInstance;

  @$pb.TagNumber(1)
  ConstArguments get constArguments => $_getN(0);
  @$pb.TagNumber(1)
  set constArguments(ConstArguments v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasConstArguments() => $_has(0);
  @$pb.TagNumber(1)
  void clearConstArguments() => clearField(1);
  @$pb.TagNumber(1)
  ConstArguments ensureConstArguments() => $_ensure(0);

  @$pb.TagNumber(2)
  NonConstArguments get nonConstArguments => $_getN(1);
  @$pb.TagNumber(2)
  set nonConstArguments(NonConstArguments v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasNonConstArguments() => $_has(1);
  @$pb.TagNumber(2)
  void clearNonConstArguments() => clearField(2);
  @$pb.TagNumber(2)
  NonConstArguments ensureNonConstArguments() => $_ensure(1);
}

class ConstArguments extends $pb.GeneratedMessage {
  factory ConstArguments({
    $core.Map<$core.int, FieldValue>? positional,
    $core.Map<$core.String, FieldValue>? named,
  }) {
    final $result = create();
    if (positional != null) {
      $result.positional.addAll(positional);
    }
    if (named != null) {
      $result.named.addAll(named);
    }
    return $result;
  }
  ConstArguments._() : super();
  factory ConstArguments.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ConstArguments.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConstArguments',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..m<$core.int, FieldValue>(1, _omitFieldNames ? '' : 'positional',
        entryClassName: 'ConstArguments.PositionalEntry',
        keyFieldType: $pb.PbFieldType.OU3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: FieldValue.create,
        valueDefaultOrMaker: FieldValue.getDefault,
        packageName: const $pb.PackageName('usages_shared'))
    ..m<$core.String, FieldValue>(2, _omitFieldNames ? '' : 'named',
        entryClassName: 'ConstArguments.NamedEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: FieldValue.create,
        valueDefaultOrMaker: FieldValue.getDefault,
        packageName: const $pb.PackageName('usages_shared'))
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ConstArguments clone() => ConstArguments()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ConstArguments copyWith(void Function(ConstArguments) updates) =>
      super.copyWith((message) => updates(message as ConstArguments))
          as ConstArguments;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConstArguments create() => ConstArguments._();
  ConstArguments createEmptyInstance() => create();
  static $pb.PbList<ConstArguments> createRepeated() =>
      $pb.PbList<ConstArguments>();
  @$core.pragma('dart2js:noInline')
  static ConstArguments getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConstArguments>(create);
  static ConstArguments? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.int, FieldValue> get positional => $_getMap(0);

  @$pb.TagNumber(2)
  $core.Map<$core.String, FieldValue> get named => $_getMap(1);
}

class NonConstArguments extends $pb.GeneratedMessage {
  factory NonConstArguments({
    $core.Iterable<$core.int>? positional,
    $core.Iterable<$core.String>? named,
  }) {
    final $result = create();
    if (positional != null) {
      $result.positional.addAll(positional);
    }
    if (named != null) {
      $result.named.addAll(named);
    }
    return $result;
  }
  NonConstArguments._() : super();
  factory NonConstArguments.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NonConstArguments.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NonConstArguments',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'positional', $pb.PbFieldType.KU3)
    ..pPS(2, _omitFieldNames ? '' : 'named')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NonConstArguments clone() => NonConstArguments()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NonConstArguments copyWith(void Function(NonConstArguments) updates) =>
      super.copyWith((message) => updates(message as NonConstArguments))
          as NonConstArguments;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NonConstArguments create() => NonConstArguments._();
  NonConstArguments createEmptyInstance() => create();
  static $pb.PbList<NonConstArguments> createRepeated() =>
      $pb.PbList<NonConstArguments>();
  @$core.pragma('dart2js:noInline')
  static NonConstArguments getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NonConstArguments>(create);
  static NonConstArguments? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get positional => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.String> get named => $_getList(1);
}

class Field extends $pb.GeneratedMessage {
  factory Field({
    $core.String? className,
    $core.String? name,
    FieldValue? value,
  }) {
    final $result = create();
    if (className != null) {
      $result.className = className;
    }
    if (name != null) {
      $result.name = name;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  Field._() : super();
  factory Field.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Field.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Field',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'className')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOM<FieldValue>(3, _omitFieldNames ? '' : 'value',
        subBuilder: FieldValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Field clone() => Field()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Field copyWith(void Function(Field) updates) =>
      super.copyWith((message) => updates(message as Field)) as Field;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Field create() => Field._();
  Field createEmptyInstance() => create();
  static $pb.PbList<Field> createRepeated() => $pb.PbList<Field>();
  @$core.pragma('dart2js:noInline')
  static Field getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Field>(create);
  static Field? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get className => $_getSZ(0);
  @$pb.TagNumber(1)
  set className($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasClassName() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  FieldValue get value => $_getN(2);
  @$pb.TagNumber(3)
  set value(FieldValue v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => clearField(3);
  @$pb.TagNumber(3)
  FieldValue ensureValue() => $_ensure(2);
}

enum FieldValue_Value {
  mapValue,
  listValue,
  intValue,
  doubleValue,
  boolValue,
  stringValue,
  nullValue,
  notSet
}

class FieldValue extends $pb.GeneratedMessage {
  factory FieldValue({
    StringMapValue? mapValue,
    ListValue? listValue,
    $core.int? intValue,
    $core.double? doubleValue,
    $core.bool? boolValue,
    $core.String? stringValue,
    $core.bool? nullValue,
  }) {
    final $result = create();
    if (mapValue != null) {
      $result.mapValue = mapValue;
    }
    if (listValue != null) {
      $result.listValue = listValue;
    }
    if (intValue != null) {
      $result.intValue = intValue;
    }
    if (doubleValue != null) {
      $result.doubleValue = doubleValue;
    }
    if (boolValue != null) {
      $result.boolValue = boolValue;
    }
    if (stringValue != null) {
      $result.stringValue = stringValue;
    }
    if (nullValue != null) {
      $result.nullValue = nullValue;
    }
    return $result;
  }
  FieldValue._() : super();
  factory FieldValue.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FieldValue.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, FieldValue_Value> _FieldValue_ValueByTag = {
    1: FieldValue_Value.mapValue,
    2: FieldValue_Value.listValue,
    3: FieldValue_Value.intValue,
    4: FieldValue_Value.doubleValue,
    5: FieldValue_Value.boolValue,
    6: FieldValue_Value.stringValue,
    7: FieldValue_Value.nullValue,
    0: FieldValue_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7])
    ..aOM<StringMapValue>(1, _omitFieldNames ? '' : 'mapValue',
        subBuilder: StringMapValue.create)
    ..aOM<ListValue>(2, _omitFieldNames ? '' : 'listValue',
        subBuilder: ListValue.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'intValue', $pb.PbFieldType.O3)
    ..a<$core.double>(
        4, _omitFieldNames ? '' : 'doubleValue', $pb.PbFieldType.OD)
    ..aOB(5, _omitFieldNames ? '' : 'boolValue')
    ..aOS(6, _omitFieldNames ? '' : 'stringValue')
    ..aOB(7, _omitFieldNames ? '' : 'nullValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FieldValue clone() => FieldValue()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FieldValue copyWith(void Function(FieldValue) updates) =>
      super.copyWith((message) => updates(message as FieldValue)) as FieldValue;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldValue create() => FieldValue._();
  FieldValue createEmptyInstance() => create();
  static $pb.PbList<FieldValue> createRepeated() => $pb.PbList<FieldValue>();
  @$core.pragma('dart2js:noInline')
  static FieldValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldValue>(create);
  static FieldValue? _defaultInstance;

  FieldValue_Value whichValue() => _FieldValue_ValueByTag[$_whichOneof(0)]!;
  void clearValue() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  StringMapValue get mapValue => $_getN(0);
  @$pb.TagNumber(1)
  set mapValue(StringMapValue v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMapValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearMapValue() => clearField(1);
  @$pb.TagNumber(1)
  StringMapValue ensureMapValue() => $_ensure(0);

  @$pb.TagNumber(2)
  ListValue get listValue => $_getN(1);
  @$pb.TagNumber(2)
  set listValue(ListValue v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasListValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearListValue() => clearField(2);
  @$pb.TagNumber(2)
  ListValue ensureListValue() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.int get intValue => $_getIZ(2);
  @$pb.TagNumber(3)
  set intValue($core.int v) {
    $_setSignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasIntValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearIntValue() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get doubleValue => $_getN(3);
  @$pb.TagNumber(4)
  set doubleValue($core.double v) {
    $_setDouble(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDoubleValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearDoubleValue() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get boolValue => $_getBF(4);
  @$pb.TagNumber(5)
  set boolValue($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasBoolValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearBoolValue() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get stringValue => $_getSZ(5);
  @$pb.TagNumber(6)
  set stringValue($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasStringValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearStringValue() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get nullValue => $_getBF(6);
  @$pb.TagNumber(7)
  set nullValue($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasNullValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearNullValue() => clearField(7);
}

class ListValue extends $pb.GeneratedMessage {
  factory ListValue({
    $core.Iterable<FieldValue>? value,
  }) {
    final $result = create();
    if (value != null) {
      $result.value.addAll(value);
    }
    return $result;
  }
  ListValue._() : super();
  factory ListValue.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListValue.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..pc<FieldValue>(1, _omitFieldNames ? '' : 'value', $pb.PbFieldType.PM,
        subBuilder: FieldValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListValue clone() => ListValue()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListValue copyWith(void Function(ListValue) updates) =>
      super.copyWith((message) => updates(message as ListValue)) as ListValue;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListValue create() => ListValue._();
  ListValue createEmptyInstance() => create();
  static $pb.PbList<ListValue> createRepeated() => $pb.PbList<ListValue>();
  @$core.pragma('dart2js:noInline')
  static ListValue getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListValue>(create);
  static ListValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<FieldValue> get value => $_getList(0);
}

class StringMapValue extends $pb.GeneratedMessage {
  factory StringMapValue({
    $core.Map<$core.String, FieldValue>? value,
  }) {
    final $result = create();
    if (value != null) {
      $result.value.addAll(value);
    }
    return $result;
  }
  StringMapValue._() : super();
  factory StringMapValue.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory StringMapValue.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StringMapValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages_shared'),
      createEmptyInstance: create)
    ..m<$core.String, FieldValue>(1, _omitFieldNames ? '' : 'value',
        entryClassName: 'StringMapValue.ValueEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: FieldValue.create,
        valueDefaultOrMaker: FieldValue.getDefault,
        packageName: const $pb.PackageName('usages_shared'))
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  StringMapValue clone() => StringMapValue()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  StringMapValue copyWith(void Function(StringMapValue) updates) =>
      super.copyWith((message) => updates(message as StringMapValue))
          as StringMapValue;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StringMapValue create() => StringMapValue._();
  StringMapValue createEmptyInstance() => create();
  static $pb.PbList<StringMapValue> createRepeated() =>
      $pb.PbList<StringMapValue>();
  @$core.pragma('dart2js:noInline')
  static StringMapValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StringMapValue>(create);
  static StringMapValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, FieldValue> get value => $_getMap(0);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
