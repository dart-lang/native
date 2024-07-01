//
//  Generated code. Do not modify.
//  source: usages_storage.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'usages_shared.pb.dart' as $0;

class Usages extends $pb.GeneratedMessage {
  factory Usages({
    $0.Metadata? metadata,
    $core.Iterable<$core.String>? uris,
    $core.Iterable<Definition>? definitions,
    $core.Iterable<Usage>? calls,
    $core.Iterable<Usage>? instances,
  }) {
    final $result = create();
    if (metadata != null) {
      $result.metadata = metadata;
    }
    if (uris != null) {
      $result.uris.addAll(uris);
    }
    if (definitions != null) {
      $result.definitions.addAll(definitions);
    }
    if (calls != null) {
      $result.calls.addAll(calls);
    }
    if (instances != null) {
      $result.instances.addAll(instances);
    }
    return $result;
  }
  Usages._() : super();
  factory Usages.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Usages.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Usages',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages'),
      createEmptyInstance: create)
    ..aOM<$0.Metadata>(1, _omitFieldNames ? '' : 'metadata',
        subBuilder: $0.Metadata.create)
    ..pPS(2, _omitFieldNames ? '' : 'uris')
    ..pc<Definition>(
        3, _omitFieldNames ? '' : 'definitions', $pb.PbFieldType.PM,
        subBuilder: Definition.create)
    ..pc<Usage>(4, _omitFieldNames ? '' : 'calls', $pb.PbFieldType.PM,
        subBuilder: Usage.create)
    ..pc<Usage>(5, _omitFieldNames ? '' : 'instances', $pb.PbFieldType.PM,
        subBuilder: Usage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Usages clone() => Usages()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Usages copyWith(void Function(Usages) updates) =>
      super.copyWith((message) => updates(message as Usages)) as Usages;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Usages create() => Usages._();
  Usages createEmptyInstance() => create();
  static $pb.PbList<Usages> createRepeated() => $pb.PbList<Usages>();
  @$core.pragma('dart2js:noInline')
  static Usages getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Usages>(create);
  static Usages? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Metadata get metadata => $_getN(0);
  @$pb.TagNumber(1)
  set metadata($0.Metadata v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMetadata() => $_has(0);
  @$pb.TagNumber(1)
  void clearMetadata() => clearField(1);
  @$pb.TagNumber(1)
  $0.Metadata ensureMetadata() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.String> get uris => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<Definition> get definitions => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<Usage> get calls => $_getList(3);

  @$pb.TagNumber(5)
  $core.List<Usage> get instances => $_getList(4);
}

class Usage extends $pb.GeneratedMessage {
  factory Usage({
    $core.int? definition,
    $core.Iterable<Reference>? references,
  }) {
    final $result = create();
    if (definition != null) {
      $result.definition = definition;
    }
    if (references != null) {
      $result.references.addAll(references);
    }
    return $result;
  }
  Usage._() : super();
  factory Usage.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Usage.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Usage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'definition', $pb.PbFieldType.OU3)
    ..pc<Reference>(2, _omitFieldNames ? '' : 'references', $pb.PbFieldType.PM,
        subBuilder: Reference.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Usage clone() => Usage()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Usage copyWith(void Function(Usage) updates) =>
      super.copyWith((message) => updates(message as Usage)) as Usage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Usage create() => Usage._();
  Usage createEmptyInstance() => create();
  static $pb.PbList<Usage> createRepeated() => $pb.PbList<Usage>();
  @$core.pragma('dart2js:noInline')
  static Usage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Usage>(create);
  static Usage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get definition => $_getIZ(0);
  @$pb.TagNumber(1)
  set definition($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDefinition() => $_has(0);
  @$pb.TagNumber(1)
  void clearDefinition() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Reference> get references => $_getList(1);
}

class Location extends $pb.GeneratedMessage {
  factory Location({
    $core.int? uri,
    $core.int? line,
    $core.int? column,
  }) {
    final $result = create();
    if (uri != null) {
      $result.uri = uri;
    }
    if (line != null) {
      $result.line = line;
    }
    if (column != null) {
      $result.column = column;
    }
    return $result;
  }
  Location._() : super();
  factory Location.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Location.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Location',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'uri', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'line', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'column', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Location clone() => Location()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Location copyWith(void Function(Location) updates) =>
      super.copyWith((message) => updates(message as Location)) as Location;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Location create() => Location._();
  Location createEmptyInstance() => create();
  static $pb.PbList<Location> createRepeated() => $pb.PbList<Location>();
  @$core.pragma('dart2js:noInline')
  static Location getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Location>(create);
  static Location? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get uri => $_getIZ(0);
  @$pb.TagNumber(1)
  set uri($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get line => $_getIZ(1);
  @$pb.TagNumber(2)
  set line($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get column => $_getIZ(2);
  @$pb.TagNumber(3)
  set column($core.int v) {
    $_setUnsignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasColumn() => $_has(2);
  @$pb.TagNumber(3)
  void clearColumn() => clearField(3);
}

enum Reference_Reference { arguments, fields, notSet }

class Reference extends $pb.GeneratedMessage {
  factory Reference({
    Location? location,
    $core.String? loadingUnit,
    $0.Arguments? arguments,
    $0.Fields? fields,
  }) {
    final $result = create();
    if (location != null) {
      $result.location = location;
    }
    if (loadingUnit != null) {
      $result.loadingUnit = loadingUnit;
    }
    if (arguments != null) {
      $result.arguments = arguments;
    }
    if (fields != null) {
      $result.fields = fields;
    }
    return $result;
  }
  Reference._() : super();
  factory Reference.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Reference.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Reference_Reference>
      _Reference_ReferenceByTag = {
    3: Reference_Reference.arguments,
    4: Reference_Reference.fields,
    0: Reference_Reference.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reference',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages'),
      createEmptyInstance: create)
    ..oo(0, [3, 4])
    ..aOM<Location>(1, _omitFieldNames ? '' : 'location',
        subBuilder: Location.create)
    ..aOS(2, _omitFieldNames ? '' : 'loadingUnit')
    ..aOM<$0.Arguments>(3, _omitFieldNames ? '' : 'arguments',
        subBuilder: $0.Arguments.create)
    ..aOM<$0.Fields>(4, _omitFieldNames ? '' : 'fields',
        subBuilder: $0.Fields.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Reference clone() => Reference()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Reference copyWith(void Function(Reference) updates) =>
      super.copyWith((message) => updates(message as Reference)) as Reference;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Reference create() => Reference._();
  Reference createEmptyInstance() => create();
  static $pb.PbList<Reference> createRepeated() => $pb.PbList<Reference>();
  @$core.pragma('dart2js:noInline')
  static Reference getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Reference>(create);
  static Reference? _defaultInstance;

  Reference_Reference whichReference() =>
      _Reference_ReferenceByTag[$_whichOneof(0)]!;
  void clearReference() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Location get location => $_getN(0);
  @$pb.TagNumber(1)
  set location(Location v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasLocation() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocation() => clearField(1);
  @$pb.TagNumber(1)
  Location ensureLocation() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get loadingUnit => $_getSZ(1);
  @$pb.TagNumber(2)
  set loadingUnit($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLoadingUnit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoadingUnit() => clearField(2);

  @$pb.TagNumber(3)
  $0.Arguments get arguments => $_getN(2);
  @$pb.TagNumber(3)
  set arguments($0.Arguments v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasArguments() => $_has(2);
  @$pb.TagNumber(3)
  void clearArguments() => clearField(3);
  @$pb.TagNumber(3)
  $0.Arguments ensureArguments() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Fields get fields => $_getN(3);
  @$pb.TagNumber(4)
  set fields($0.Fields v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasFields() => $_has(3);
  @$pb.TagNumber(4)
  void clearFields() => clearField(4);
  @$pb.TagNumber(4)
  $0.Fields ensureFields() => $_ensure(3);
}

class Definition extends $pb.GeneratedMessage {
  factory Definition({
    Identifier? identifier,
    $core.int? line,
    $core.int? column,
    $core.String? loadingUnit,
  }) {
    final $result = create();
    if (identifier != null) {
      $result.identifier = identifier;
    }
    if (line != null) {
      $result.line = line;
    }
    if (column != null) {
      $result.column = column;
    }
    if (loadingUnit != null) {
      $result.loadingUnit = loadingUnit;
    }
    return $result;
  }
  Definition._() : super();
  factory Definition.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Definition.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Definition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages'),
      createEmptyInstance: create)
    ..aOM<Identifier>(1, _omitFieldNames ? '' : 'identifier',
        subBuilder: Identifier.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'line', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'column', $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'loadingUnit')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Definition clone() => Definition()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Definition copyWith(void Function(Definition) updates) =>
      super.copyWith((message) => updates(message as Definition)) as Definition;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Definition create() => Definition._();
  Definition createEmptyInstance() => create();
  static $pb.PbList<Definition> createRepeated() => $pb.PbList<Definition>();
  @$core.pragma('dart2js:noInline')
  static Definition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Definition>(create);
  static Definition? _defaultInstance;

  @$pb.TagNumber(1)
  Identifier get identifier => $_getN(0);
  @$pb.TagNumber(1)
  set identifier(Identifier v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentifier() => clearField(1);
  @$pb.TagNumber(1)
  Identifier ensureIdentifier() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get line => $_getIZ(1);
  @$pb.TagNumber(2)
  set line($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get column => $_getIZ(2);
  @$pb.TagNumber(3)
  set column($core.int v) {
    $_setUnsignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasColumn() => $_has(2);
  @$pb.TagNumber(3)
  void clearColumn() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get loadingUnit => $_getSZ(3);
  @$pb.TagNumber(4)
  set loadingUnit($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasLoadingUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLoadingUnit() => clearField(4);
}

class Identifier extends $pb.GeneratedMessage {
  factory Identifier({
    $core.int? uri,
    $core.String? parent,
    $core.String? name,
  }) {
    final $result = create();
    if (uri != null) {
      $result.uri = uri;
    }
    if (parent != null) {
      $result.parent = parent;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  Identifier._() : super();
  factory Identifier.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Identifier.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Identifier',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'usages'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'uri', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'parent')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Identifier clone() => Identifier()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Identifier copyWith(void Function(Identifier) updates) =>
      super.copyWith((message) => updates(message as Identifier)) as Identifier;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Identifier create() => Identifier._();
  Identifier createEmptyInstance() => create();
  static $pb.PbList<Identifier> createRepeated() => $pb.PbList<Identifier>();
  @$core.pragma('dart2js:noInline')
  static Identifier getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Identifier>(create);
  static Identifier? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get uri => $_getIZ(0);
  @$pb.TagNumber(1)
  set uri($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get parent => $_getSZ(1);
  @$pb.TagNumber(2)
  set parent($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasParent() => $_has(1);
  @$pb.TagNumber(2)
  void clearParent() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
