// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/availability.dart';
import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../ast_node.dart';

/// Describes a built-in Swift type (e.g Int, String, etc).
class BuiltInDeclaration extends AstNode
    implements Declaration, ObjCAnnotatable {
  @override
  final String id;

  @override
  final String name;

  @override
  List<AvailabilityInfo> get availability => const [];

  @override
  bool get hasObjCAnnotation => true;

  const BuiltInDeclaration({
    required this.id,
    required this.name,
  });

  @override
  void visit(Visitation visitation) => visitation.visitBuiltInDeclaration(this);
}

const _intDecl = BuiltInDeclaration(id: 's:Si', name: 'Int');
const _floatDecl = BuiltInDeclaration(id: 's:Sf', name: 'Float');
const _doubleDecl = BuiltInDeclaration(id: 's:Sd', name: 'Double');
const _boolDecl = BuiltInDeclaration(id: 's:Sb', name: 'Bool');
const _voidDecl = BuiltInDeclaration(id: 's:s4Voida', name: 'Void');

// Certain types are toll-free bridged between Swift and ObjC. These types don't
// need @objc compatible wrappers. There's no complete list of these types in
// the documentation. The closest thing is this, but it's missing a lot of
// entries, and also contains incorrect entries:
// https://developer.apple.com/documentation/swift/working-with-foundation-types
const _objectDecl =
    BuiltInDeclaration(id: 'c:objc(cs)NSObject', name: 'NSObject');
const _errorDecl = BuiltInDeclaration(id: 'c:objc(cs)NSError', name: 'NSError');
const _affineTransformDecl = BuiltInDeclaration(
    id: 's:10Foundation15AffineTransformV', name: 'AffineTransform');
const _arrayDecl = BuiltInDeclaration(id: 's:Sa', name: 'Array');
const _calendarDecl =
    BuiltInDeclaration(id: 's:10Foundation8CalendarV', name: 'Calendar');
const _characterSetDecl = BuiltInDeclaration(
    id: 's:10Foundation12CharacterSetV', name: 'CharacterSet');
const _dataDecl = BuiltInDeclaration(id: 's:10Foundation4DataV', name: 'Data');
const _dateDecl = BuiltInDeclaration(id: 's:10Foundation4DateV', name: 'Date');
const _dateComponentsDecl = BuiltInDeclaration(
    id: 's:10Foundation14DateComponentsV', name: 'DateComponents');
const _dateIntervalDecl = BuiltInDeclaration(
    id: 's:10Foundation12DateIntervalV', name: 'DateInterval');
const _dictionaryDecl = BuiltInDeclaration(id: 's:SD', name: 'Dictionary');
const _indexPathDecl =
    BuiltInDeclaration(id: 's:10Foundation9IndexPathV', name: 'IndexPath');
const _indexSetDecl =
    BuiltInDeclaration(id: 's:10Foundation8IndexSetV', name: 'IndexSet');
const _localeDecl =
    BuiltInDeclaration(id: 's:10Foundation6LocaleV', name: 'Locale');
const _notificationDecl = BuiltInDeclaration(
    id: 's:10Foundation12NotificationV', name: 'Notification');
const _setDecl = BuiltInDeclaration(id: 's:Sh', name: 'Set');
const _stringDecl = BuiltInDeclaration(id: 's:SS', name: 'String');
const _timeZoneDecl =
    BuiltInDeclaration(id: 's:10Foundation8TimeZoneV', name: 'TimeZone');
const _urlDecl = BuiltInDeclaration(id: 's:10Foundation3URLV', name: 'URL');
const _urlComponentsDecl = BuiltInDeclaration(
    id: 's:10Foundation13URLComponentsV', name: 'URLComponents');
const _urlQueryItemDecl = BuiltInDeclaration(
    id: 's:10Foundation12URLQueryItemV', name: 'URLQueryItem');
const _urlRequestDecl =
    BuiltInDeclaration(id: 's:10Foundation10URLRequestV', name: 'URLRequest');
const _uuidDecl = BuiltInDeclaration(id: 's:10Foundation4UUIDV', name: 'UUID');

const builtInDeclarations = [
  _affineTransformDecl,
  _arrayDecl,
  _boolDecl,
  _calendarDecl,
  _characterSetDecl,
  _dataDecl,
  _dateComponentsDecl,
  _dateDecl,
  _dateIntervalDecl,
  _dictionaryDecl,
  _doubleDecl,
  _errorDecl,
  _floatDecl,
  _indexPathDecl,
  _indexSetDecl,
  _intDecl,
  _localeDecl,
  _notificationDecl,
  _objectDecl,
  _setDecl,
  _stringDecl,
  _timeZoneDecl,
  _urlComponentsDecl,
  _urlDecl,
  _urlQueryItemDecl,
  _urlRequestDecl,
  _uuidDecl,
  _voidDecl,
];

final objectType = _objectDecl.asDeclaredType;
final stringType = _stringDecl.asDeclaredType;
final intType = _intDecl.asDeclaredType;
final floatType = _floatDecl.asDeclaredType;
final doubleType = _doubleDecl.asDeclaredType;
final boolType = _boolDecl.asDeclaredType;
final voidType = _voidDecl.asDeclaredType;
