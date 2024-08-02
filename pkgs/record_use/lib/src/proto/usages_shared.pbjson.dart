//
//  Generated code. Do not modify.
//  source: usages_shared.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use metadataDescriptor instead')
const Metadata$json = {
  '1': 'Metadata',
  '2': [
    {
      '1': 'comment',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'comment',
      '17': true
    },
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
  ],
  '8': [
    {'1': '_comment'},
  ],
};

/// Descriptor for `Metadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metadataDescriptor = $convert.base64Decode(
    'CghNZXRhZGF0YRIdCgdjb21tZW50GAEgASgJSABSB2NvbW1lbnSIAQESGAoHdmVyc2lvbhgCIA'
    'EoCVIHdmVyc2lvbkIKCghfY29tbWVudA==');

@$core.Deprecated('Use fieldsDescriptor instead')
const Fields$json = {
  '1': 'Fields',
  '2': [
    {
      '1': 'fields',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.usages_shared.Field',
      '10': 'fields'
    },
  ],
};

/// Descriptor for `Fields`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldsDescriptor = $convert.base64Decode(
    'CgZGaWVsZHMSLAoGZmllbGRzGAEgAygLMhQudXNhZ2VzX3NoYXJlZC5GaWVsZFIGZmllbGRz');

@$core.Deprecated('Use argumentsDescriptor instead')
const Arguments$json = {
  '1': 'Arguments',
  '2': [
    {
      '1': 'const_arguments',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.ConstArguments',
      '10': 'constArguments'
    },
    {
      '1': 'non_const_arguments',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.NonConstArguments',
      '10': 'nonConstArguments'
    },
  ],
};

/// Descriptor for `Arguments`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List argumentsDescriptor = $convert.base64Decode(
    'CglBcmd1bWVudHMSRgoPY29uc3RfYXJndW1lbnRzGAEgASgLMh0udXNhZ2VzX3NoYXJlZC5Db2'
    '5zdEFyZ3VtZW50c1IOY29uc3RBcmd1bWVudHMSUAoTbm9uX2NvbnN0X2FyZ3VtZW50cxgCIAEo'
    'CzIgLnVzYWdlc19zaGFyZWQuTm9uQ29uc3RBcmd1bWVudHNSEW5vbkNvbnN0QXJndW1lbnRz');

@$core.Deprecated('Use constArgumentsDescriptor instead')
const ConstArguments$json = {
  '1': 'ConstArguments',
  '2': [
    {
      '1': 'positional',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.usages_shared.ConstArguments.PositionalEntry',
      '10': 'positional'
    },
    {
      '1': 'named',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.usages_shared.ConstArguments.NamedEntry',
      '10': 'named'
    },
  ],
  '3': [ConstArguments_PositionalEntry$json, ConstArguments_NamedEntry$json],
};

@$core.Deprecated('Use constArgumentsDescriptor instead')
const ConstArguments_PositionalEntry$json = {
  '1': 'PositionalEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.FieldValue',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use constArgumentsDescriptor instead')
const ConstArguments_NamedEntry$json = {
  '1': 'NamedEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.FieldValue',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `ConstArguments`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List constArgumentsDescriptor = $convert.base64Decode(
    'Cg5Db25zdEFyZ3VtZW50cxJNCgpwb3NpdGlvbmFsGAEgAygLMi0udXNhZ2VzX3NoYXJlZC5Db2'
    '5zdEFyZ3VtZW50cy5Qb3NpdGlvbmFsRW50cnlSCnBvc2l0aW9uYWwSPgoFbmFtZWQYAiADKAsy'
    'KC51c2FnZXNfc2hhcmVkLkNvbnN0QXJndW1lbnRzLk5hbWVkRW50cnlSBW5hbWVkGlgKD1Bvc2'
    'l0aW9uYWxFbnRyeRIQCgNrZXkYASABKA1SA2tleRIvCgV2YWx1ZRgCIAEoCzIZLnVzYWdlc19z'
    'aGFyZWQuRmllbGRWYWx1ZVIFdmFsdWU6AjgBGlMKCk5hbWVkRW50cnkSEAoDa2V5GAEgASgJUg'
    'NrZXkSLwoFdmFsdWUYAiABKAsyGS51c2FnZXNfc2hhcmVkLkZpZWxkVmFsdWVSBXZhbHVlOgI4'
    'AQ==');

@$core.Deprecated('Use nonConstArgumentsDescriptor instead')
const NonConstArguments$json = {
  '1': 'NonConstArguments',
  '2': [
    {'1': 'positional', '3': 1, '4': 3, '5': 13, '10': 'positional'},
    {'1': 'named', '3': 2, '4': 3, '5': 9, '10': 'named'},
  ],
};

/// Descriptor for `NonConstArguments`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nonConstArgumentsDescriptor = $convert.base64Decode(
    'ChFOb25Db25zdEFyZ3VtZW50cxIeCgpwb3NpdGlvbmFsGAEgAygNUgpwb3NpdGlvbmFsEhQKBW'
    '5hbWVkGAIgAygJUgVuYW1lZA==');

@$core.Deprecated('Use fieldDescriptor instead')
const Field$json = {
  '1': 'Field',
  '2': [
    {'1': 'class_name', '3': 1, '4': 1, '5': 9, '10': 'className'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'value',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.FieldValue',
      '10': 'value'
    },
  ],
};

/// Descriptor for `Field`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldDescriptor = $convert.base64Decode(
    'CgVGaWVsZBIdCgpjbGFzc19uYW1lGAEgASgJUgljbGFzc05hbWUSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIvCgV2YWx1ZRgDIAEoCzIZLnVzYWdlc19zaGFyZWQuRmllbGRWYWx1ZVIFdmFsdWU=');

@$core.Deprecated('Use fieldValueDescriptor instead')
const FieldValue$json = {
  '1': 'FieldValue',
  '2': [
    {
      '1': 'map_value',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.StringMapValue',
      '9': 0,
      '10': 'mapValue'
    },
    {
      '1': 'list_value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.ListValue',
      '9': 0,
      '10': 'listValue'
    },
    {'1': 'int_value', '3': 3, '4': 1, '5': 5, '9': 0, '10': 'intValue'},
    {'1': 'double_value', '3': 4, '4': 1, '5': 1, '9': 0, '10': 'doubleValue'},
    {'1': 'bool_value', '3': 5, '4': 1, '5': 8, '9': 0, '10': 'boolValue'},
    {'1': 'string_value', '3': 6, '4': 1, '5': 9, '9': 0, '10': 'stringValue'},
    {'1': 'null_value', '3': 7, '4': 1, '5': 8, '9': 0, '10': 'nullValue'},
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `FieldValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldValueDescriptor = $convert.base64Decode(
    'CgpGaWVsZFZhbHVlEjwKCW1hcF92YWx1ZRgBIAEoCzIdLnVzYWdlc19zaGFyZWQuU3RyaW5nTW'
    'FwVmFsdWVIAFIIbWFwVmFsdWUSOQoKbGlzdF92YWx1ZRgCIAEoCzIYLnVzYWdlc19zaGFyZWQu'
    'TGlzdFZhbHVlSABSCWxpc3RWYWx1ZRIdCglpbnRfdmFsdWUYAyABKAVIAFIIaW50VmFsdWUSIw'
    'oMZG91YmxlX3ZhbHVlGAQgASgBSABSC2RvdWJsZVZhbHVlEh8KCmJvb2xfdmFsdWUYBSABKAhI'
    'AFIJYm9vbFZhbHVlEiMKDHN0cmluZ192YWx1ZRgGIAEoCUgAUgtzdHJpbmdWYWx1ZRIfCgpudW'
    'xsX3ZhbHVlGAcgASgISABSCW51bGxWYWx1ZUIHCgV2YWx1ZQ==');

@$core.Deprecated('Use listValueDescriptor instead')
const ListValue$json = {
  '1': 'ListValue',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.usages_shared.FieldValue',
      '10': 'value'
    },
  ],
};

/// Descriptor for `ListValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listValueDescriptor = $convert.base64Decode(
    'CglMaXN0VmFsdWUSLwoFdmFsdWUYASADKAsyGS51c2FnZXNfc2hhcmVkLkZpZWxkVmFsdWVSBX'
    'ZhbHVl');

@$core.Deprecated('Use stringMapValueDescriptor instead')
const StringMapValue$json = {
  '1': 'StringMapValue',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.usages_shared.StringMapValue.ValueEntry',
      '10': 'value'
    },
  ],
  '3': [StringMapValue_ValueEntry$json],
};

@$core.Deprecated('Use stringMapValueDescriptor instead')
const StringMapValue_ValueEntry$json = {
  '1': 'ValueEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.usages_shared.FieldValue',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `StringMapValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringMapValueDescriptor = $convert.base64Decode(
    'Cg5TdHJpbmdNYXBWYWx1ZRI+CgV2YWx1ZRgBIAMoCzIoLnVzYWdlc19zaGFyZWQuU3RyaW5nTW'
    'FwVmFsdWUuVmFsdWVFbnRyeVIFdmFsdWUaUwoKVmFsdWVFbnRyeRIQCgNrZXkYASABKAlSA2tl'
    'eRIvCgV2YWx1ZRgCIAEoCzIZLnVzYWdlc19zaGFyZWQuRmllbGRWYWx1ZVIFdmFsdWU6AjgB');
