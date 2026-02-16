// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../config.dart';
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
  final int? lineNumber;

  @override
  InputConfig? get source => null;

  @override
  List<AvailabilityInfo> get availability => const [];

  @override
  bool get hasObjCAnnotation => true;

  const BuiltInDeclaration({
    required this.id,
    required this.name,
    this.lineNumber,
  });

  @override
  void visit(Visitation visitation) => visitation.visitBuiltInDeclaration(this);
}

const _intDecl = BuiltInDeclaration(id: 's:Si', name: 'Int');
const _floatDecl = BuiltInDeclaration(id: 's:Sf', name: 'Float');
const _doubleDecl = BuiltInDeclaration(id: 's:Sd', name: 'Double');
const _boolDecl = BuiltInDeclaration(id: 's:Sb', name: 'Bool');
const _voidDecl = BuiltInDeclaration(id: 's:s4Voida', name: 'Void');
const _objectDecl = BuiltInDeclaration(
  id: 'c:objc(cs)NSObject',
  name: 'NSObject',
);
const _stringDecl = BuiltInDeclaration(id: 's:SS', name: 'String');
const _selfDecl = BuiltInDeclaration(id: '', name: 'Self');

final objectType = _objectDecl.asDeclaredType;
final stringType = _stringDecl.asDeclaredType;
final intType = _intDecl.asDeclaredType;
final floatType = _floatDecl.asDeclaredType;
final doubleType = _doubleDecl.asDeclaredType;
final boolType = _boolDecl.asDeclaredType;
final voidType = _voidDecl.asDeclaredType;
final selfType = _selfDecl.asDeclaredType;

const builtInDeclarations = [
  _boolDecl,
  _doubleDecl,
  _floatDecl,
  _intDecl,
  _objectDecl,
  _stringDecl,
  _voidDecl,

  // TODO(https://github.com/dart-lang/native/issues/2954): This shouldn't be
  // treated as an ordinary built-in.
  BuiltInDeclaration(id: 's:s6HasherV', name: 'Hasher'),

  // Certain types are toll-free bridged between Swift and ObjC. These types
  // don't need @objc compatible wrappers. There's no complete list of these
  // types in the documentation. The closest thing is this, but it's incomplete:
  // https://developer.apple.com/documentation/swift/working-with-foundation-types
  // TODO(https://github.com/dart-lang/native/issues/2485): Add Array, Set, and
  // Dictionary to this list.
  BuiltInDeclaration(
    id: 's:10Foundation15AffineTransformV',
    name: 'AffineTransform',
  ),
  BuiltInDeclaration(id: 's:10Foundation8CalendarV', name: 'Calendar'),
  BuiltInDeclaration(id: 's:10Foundation12CharacterSetV', name: 'CharacterSet'),
  BuiltInDeclaration(id: 's:10Foundation4DataV', name: 'Data'),
  BuiltInDeclaration(id: 's:10Foundation4DateV', name: 'Date'),
  BuiltInDeclaration(
    id: 's:10Foundation14DateComponentsV',
    name: 'DateComponents',
  ),
  BuiltInDeclaration(id: 's:10Foundation12DateIntervalV', name: 'DateInterval'),
  BuiltInDeclaration(id: 's:10Foundation9IndexPathV', name: 'IndexPath'),
  BuiltInDeclaration(id: 's:10Foundation8IndexSetV', name: 'IndexSet'),
  BuiltInDeclaration(id: 's:10Foundation6LocaleV', name: 'Locale'),
  BuiltInDeclaration(id: 's:10Foundation12NotificationV', name: 'Notification'),
  BuiltInDeclaration(id: 's:10Foundation8TimeZoneV', name: 'TimeZone'),
  BuiltInDeclaration(id: 's:10Foundation3URLV', name: 'URL'),
  BuiltInDeclaration(
    id: 's:10Foundation13URLComponentsV',
    name: 'URLComponents',
  ),
  BuiltInDeclaration(id: 's:10Foundation12URLQueryItemV', name: 'URLQueryItem'),
  BuiltInDeclaration(id: 's:10Foundation10URLRequestV', name: 'URLRequest'),
  BuiltInDeclaration(id: 's:10Foundation4UUIDV', name: 'UUID'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSNetServiceBrowser',
    name: 'NetServiceBrowser',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSAttributedString ',
    name: 'NSAttributedString',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSMeasurement', name: 'NSMeasurement'),
  BuiltInDeclaration(id: 'c:objc(cs)NSCoder', name: 'NSCoder'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUniqueIDSpecifier',
    name: 'NSUniqueIDSpecifier',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSData ', name: 'NSData'),
  BuiltInDeclaration(id: 'c:objc(cs)NSNetService ', name: 'NetService'),
  BuiltInDeclaration(id: 'c:objc(cs)NSProgress ', name: 'Progress'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSPointerFunctions ',
    name: 'NSPointerFunctions',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSProcessInfo', name: 'ProcessInfo'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSCachedURLResponse',
    name: 'CachedURLResponse',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSNotification ', name: 'NSNotification'),
  BuiltInDeclaration(id: 'c:objc(cs)NSOperationQueue ', name: 'OperationQueue'),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLQueryItem ', name: 'NSURLQueryItem'),
  BuiltInDeclaration(id: 'c:objc(cs)NSXMLParser', name: 'XMLParser'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSPersonNameComponents ',
    name: 'NSPersonNameComponents',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSKeyedArchiver', name: 'NSKeyedArchiver'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLCredentialStorage ',
    name: 'URLCredentialStorage',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSDecimalNumberHandler ',
    name: 'NSDecimalNumberHandler',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionWebSocketTask',
    name: 'URLSessionWebSocketTask',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSFileCoordinator',
    name: 'NSFileCoordinator',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSLocale ', name: 'NSLocale'),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLSession ', name: 'URLSession'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionDataTask ',
    name: 'URLSessionDataTask',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLResponse', name: 'URLResponse'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitElectricCharge ',
    name: 'UnitElectricCharge',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitDuration ', name: 'UnitDuration'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionDownloadTask ',
    name: 'URLSessionDownloadTask',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitConverterLinear',
    name: 'UnitConverterLinear',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionTaskTransactionMetrics ',
    name: 'URLSessionTaskTransactionMetrics',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitDispersion ', name: 'UnitDispersion'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionStreamTask ',
    name: 'URLSessionStreamTask',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitConverter', name: 'UnitConverter'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSExtensionContext ',
    name: 'NSExtensionContext',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionUploadTask ',
    name: 'URLSessionUploadTask',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSDateComponents ',
    name: 'NSDateComponents',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitConcentrationMass',
    name: 'UnitConcentrationMass',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitArea ', name: 'UnitArea'),
  BuiltInDeclaration(id: 'c:objc(cs)NSInputStream', name: 'InputStream'),
  BuiltInDeclaration(id: 'c:objc(cs)NSOutputStream ', name: 'OutputStream'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitAngle', name: 'UnitAngle'),
  BuiltInDeclaration(id: 'c:objc(cs)NSExtensionItem', name: 'NSExtensionItem'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitAcceleration ',
    name: 'UnitAcceleration',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSXMLNode', name: 'XMLNode'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUbiquitousKeyValueStore',
    name: 'NSUbiquitousKeyValueStore',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSFileAccessIntent ',
    name: 'NSFileAccessIntent',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLCredential', name: 'URLCredential'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUUID ', name: 'NSUUID'),
  BuiltInDeclaration(id: 'c:objc(cs)NSXPCListener', name: 'NSXPCListener'),
  BuiltInDeclaration(id: 'c:objc(cs)NSXPCConnection', name: 'NSXPCConnection'),
  BuiltInDeclaration(id: 'c:objc(cs)NSDataDetector ', name: 'NSDataDetector'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSRegularExpression',
    name: 'NSRegularExpression',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUndoManager', name: 'UndoManager'),
  BuiltInDeclaration(id: 'c:objc(cs)NSFileSecurity ', name: 'NSFileSecurity'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnarchiver ', name: 'NSUnarchiver'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSPropertyListSerialization',
    name: 'PropertyListSerialization',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLComponents', name: 'NSURLComponents'),
  BuiltInDeclaration(id: 'c:objc(cs)NSCalendar ', name: 'NSCalendar'),
  BuiltInDeclaration(id: 'c:objc(cs)NSExpression ', name: 'NSExpression'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUserScriptTask ',
    name: 'NSUserScriptTask',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUserAppleScriptTask',
    name: 'NSUserAppleScriptTask',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSCache', name: 'NSCache'),
  BuiltInDeclaration(id: 'c:objc(cs)NSCharacterSet ', name: 'NSCharacterSet'),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLConnection', name: 'NSURLConnection'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUserAutomatorTask',
    name: 'NSUserAutomatorTask',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSScriptCommand', name: 'NSScriptCommand'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSOrderedCollectionDifference',
    name: 'NSOrderedCollectionDifference',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSCloneCommand ', name: 'NSCloneCommand'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSOrderedCollectionChange',
    name: 'NSOrderedCollectionChange',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSClassDescription ',
    name: 'NSClassDescription',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSError', name: 'NSError'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUserActivity ', name: 'NSUserActivity'),
  BuiltInDeclaration(id: 'c:objc(cs)NSArray', name: 'NSArray'),
  BuiltInDeclaration(id: 'c:objc(cs)NSCloseCommand ', name: 'NSCloseCommand'),
  BuiltInDeclaration(id: 'c:objc(cs)NSEnumerator ', name: 'NSEnumerator'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSDirectoryEnumerator',
    name: 'DirectoryEnumerator',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSDateComponentsFormatter',
    name: 'DateComponentsFormatter',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUserNotificationCenter ',
    name: 'NSUserNotificationCenter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSIndexPath', name: 'NSIndexPath'),
  BuiltInDeclaration(id: 'c:objc(cs)NSOrthography', name: 'NSOrthography'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMapTable ', name: 'NSMapTable'),
  BuiltInDeclaration(id: 'c:objc(cs)NSPortMessage', name: 'PortMessage'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSAffineTransform',
    name: 'NSAffineTransform',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSProxy', name: 'NSProxy'),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLSessionTask ', name: 'URLSessionTask'),
  BuiltInDeclaration(id: 'c:objc(cs)NSFileManager', name: 'FileManager'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSPersonNameComponentsFormatter',
    name: 'PersonNameComponentsFormatter',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionConfiguration',
    name: 'URLSessionConfiguration',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUserNotification ',
    name: 'NSUserNotification',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUserNotificationAction ',
    name: 'NSUserNotificationAction',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitIlluminance',
    name: 'UnitIlluminance',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSDecimalNumber', name: 'NSDecimalNumber'),
  BuiltInDeclaration(id: 'c:objc(cs)NSLogicalTest', name: 'NSLogicalTest'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSScriptWhoseTest',
    name: 'NSScriptWhoseTest',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitInformationStorage ',
    name: 'UnitInformationStorage',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitFrequency', name: 'UnitFrequency'),
  BuiltInDeclaration(id: 'c:objc(cs)NSTimeZone ', name: 'NSTimeZone'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitFuelEfficiency ',
    name: 'UnitFuelEfficiency',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitElectricResistance ',
    name: 'UnitElectricResistance',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSSortDescriptor ',
    name: 'NSSortDescriptor',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSMachPort ', name: 'NSMachPort'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitEnergy ', name: 'UnitEnergy'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSNotificationCenter ',
    name: 'NotificationCenter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSPipe ', name: 'Pipe'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitElectricCurrent',
    name: 'UnitElectricCurrent',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSDateFormatter', name: 'DateFormatter'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitElectricPotentialDifference',
    name: 'UnitElectricPotentialDifference',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSDateIntervalFormatter',
    name: 'DateIntervalFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSPointerArray ', name: 'NSPointerArray'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSByteCountFormatter ',
    name: 'ByteCountFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitVolume ', name: 'UnitVolume'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitSpeed', name: 'UnitSpeed'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLSessionTaskMetrics',
    name: 'URLSessionTaskMetrics',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLProtocol', name: 'URLProtocol'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSUnitTemperature',
    name: 'UnitTemperature',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSDateInterval ', name: 'NSDateInterval'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitPower', name: 'UnitPower'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitPressure ', name: 'UnitPressure'),
  BuiltInDeclaration(id: 'c:objc(cs)NSIndexSet ', name: 'NSIndexSet'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSBackgroundActivityScheduler',
    name: 'NSBackgroundActivityScheduler',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitLength ', name: 'UnitLength'),
  BuiltInDeclaration(id: 'c:objc(cs)NSLock ', name: 'NSLock'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnitMass ', name: 'UnitMass'),
  BuiltInDeclaration(id: 'c:objc(cs)NSString ', name: 'NSString'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSRelativeSpecifier',
    name: 'NSRelativeSpecifier',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSNull ', name: 'NSNull'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSDistributedNotificationCenter',
    name: 'DistributedNotificationCenter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSHashTable', name: 'NSHashTable'),
  BuiltInDeclaration(id: 'c:objc(cs)NSRunLoop', name: 'RunLoop'),
  BuiltInDeclaration(id: 'c:objc(cs)NSURL', name: 'NSURL'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSNumberFormatter',
    name: 'NumberFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSBundle ', name: 'Bundle'),
  BuiltInDeclaration(id: 'c:objc(cs)NSXMLDocument', name: 'XMLDocument'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSLinguisticTagger ',
    name: 'NSLinguisticTagger',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSISO8601DateFormatter ',
    name: 'ISO8601DateFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSHost ', name: 'Host'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSWhoseSpecifier ',
    name: 'NSWhoseSpecifier',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSSpellServer', name: 'NSSpellServer'),
  BuiltInDeclaration(id: 'c:objc(cs)NSFileHandle ', name: 'FileHandle'),
  BuiltInDeclaration(id: 'c:objc(cs)NSFormatter', name: 'Formatter'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMetadataQuery', name: 'NSMetadataQuery'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMetadataItem ', name: 'NSMetadataItem'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSAppleEventDescriptor ',
    name: 'NSAppleEventDescriptor',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSUserUnixTask ', name: 'NSUserUnixTask'),
  BuiltInDeclaration(id: 'c:objc(cs)NSXMLDTD ', name: 'XMLDTD'),
  BuiltInDeclaration(id: 'c:objc(cs)NSScanner', name: 'Scanner'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSScriptClassDescription ',
    name: 'NSScriptClassDescription',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSScriptCoercionHandler',
    name: 'NSScriptCoercionHandler',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSScriptCommandDescription ',
    name: 'NSScriptCommandDescription',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSXMLDTDNode ', name: 'XMLDTDNode'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSScriptExecutionContext ',
    name: 'NSScriptExecutionContext',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSScriptSuiteRegistry',
    name: 'NSScriptSuiteRegistry',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSCreateCommand', name: 'NSCreateCommand'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMutableIndexSet',
    name: 'NSMutableIndexSet',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSSet', name: 'NSSet'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMutableSet ', name: 'NSMutableSet'),
  BuiltInDeclaration(id: 'c:objc(cs)NSXPCInterface ', name: 'NSXPCInterface'),
  BuiltInDeclaration(id: 'c:objc(cs)NSCountedSet ', name: 'NSCountedSet'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMutableDictionary',
    name: 'NSMutableDictionary',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSStream ', name: 'Stream'),
  BuiltInDeclaration(id: 'c:objc(cs)NSCountCommand ', name: 'NSCountCommand'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSXPCListenerEndpoint',
    name: 'NSXPCListenerEndpoint',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSJSONSerialization',
    name: 'JSONSerialization',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSAssertionHandler ',
    name: 'NSAssertionHandler',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMutableURLRequest',
    name: 'NSMutableURLRequest',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLRequest ', name: 'NSURLRequest'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMutableString', name: 'NSMutableString'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMutableOrderedSet',
    name: 'NSMutableOrderedSet',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSOrderedSet ', name: 'NSOrderedSet'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSKeyedUnarchiver',
    name: 'NSKeyedUnarchiver',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLAuthenticationChallenge ',
    name: 'URLAuthenticationChallenge',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSXPCCoder ', name: 'NSXPCCoder'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSKeyValueSharedObservers',
    name: 'NSKeyValueSharedObservers',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLCache ', name: 'URLCache'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSKeyValueSharedObserversSnapshot',
    name: 'NSKeyValueSharedObserversSnapshot',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSNameSpecifier', name: 'NSNameSpecifier'),
  BuiltInDeclaration(id: 'c:objc(cs)NSExistsCommand', name: 'NSExistsCommand'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMassFormatter', name: 'MassFormatter'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMeasurementFormatter ',
    name: 'MeasurementFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSException', name: 'NSException'),
  BuiltInDeclaration(id: 'c:objc(cs)NSXMLElement ', name: 'XMLElement'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMessagePort', name: 'MessagePort'),
  BuiltInDeclaration(id: 'c:objc(cs)NSPort ', name: 'Port'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSLengthFormatter',
    name: 'LengthFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSListFormatter', name: 'ListFormatter'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSNotificationQueue',
    name: 'NotificationQueue',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSValue', name: 'NSValue'),
  BuiltInDeclaration(id: 'c:objc(cs)NSDate ', name: 'NSDate'),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLDownload', name: 'NSURLDownload'),
  BuiltInDeclaration(id: 'c:objc(cs)NSAppleScript', name: 'NSAppleScript'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSURLProtectionSpace ',
    name: 'URLProtectionSpace',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSURLHandle', name: 'NSURLHandle'),
  BuiltInDeclaration(id: 'c:objc(cs)NSNumber ', name: 'NSNumber'),
  BuiltInDeclaration(id: 'c:objc(cs)NSCondition', name: 'NSCondition'),
  BuiltInDeclaration(id: 'c:objc(cs)NSConditionLock', name: 'NSConditionLock'),
  BuiltInDeclaration(id: 'c:objc(cs)NSArchiver ', name: 'NSArchiver'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUserDefaults ', name: 'UserDefaults'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSCompoundPredicate',
    name: 'NSCompoundPredicate',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSComparisonPredicate',
    name: 'NSComparisonPredicate',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSPredicate', name: 'NSPredicate'),
  BuiltInDeclaration(id: 'c:objc(cs)NSFileWrapper', name: 'FileWrapper'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMutableCharacterSet',
    name: 'NSMutableCharacterSet',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSValueTransformer ',
    name: 'ValueTransformer',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSFileVersion', name: 'NSFileVersion'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSSecureUnarchiveFromDataTransformer ',
    name: 'NSSecureUnarchiveFromDataTransformer',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSMutableData', name: 'NSMutableData'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMiddleSpecifier',
    name: 'NSMiddleSpecifier',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMutableAttributedString',
    name: 'NSMutableAttributedString',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSMutableArray ', name: 'NSMutableArray'),
  BuiltInDeclaration(id: 'c:objc(cs)NSMoveCommand', name: 'NSMoveCommand'),
  BuiltInDeclaration(id: 'c:objc(cs)NSHTTPCookie ', name: 'HTTPCookie'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMetadataQueryResultGroup ',
    name: 'NSMetadataQueryResultGroup',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSHTTPURLResponse',
    name: 'HTTPURLResponse',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSMetadataQueryAttributeValueTuple ',
    name: 'NSMetadataQueryAttributeValueTuple',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSDistributedLock',
    name: 'NSDistributedLock',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSSpecifierTest', name: 'NSSpecifierTest'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSHTTPCookieStorage',
    name: 'HTTPCookieStorage',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSAppleEventManager',
    name: 'NSAppleEventManager',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSSocketPort ', name: 'SocketPort'),
  BuiltInDeclaration(id: 'c:objc(cs)NSItemProvider ', name: 'NSItemProvider'),
  BuiltInDeclaration(id: 'c:objc(cs)NSSetCommand ', name: 'NSSetCommand'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSPositionalSpecifier',
    name: 'NSPositionalSpecifier',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSTimer', name: 'Timer'),
  BuiltInDeclaration(id: 'c:objc(cs)NSTask ', name: 'Process'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSIndexSpecifier ',
    name: 'NSIndexSpecifier',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSScriptObjectSpecifier',
    name: 'NSScriptObjectSpecifier',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSTextCheckingResult ',
    name: 'NSTextCheckingResult',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSGetCommand ', name: 'NSGetCommand'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSPropertySpecifier',
    name: 'NSPropertySpecifier',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSDictionary ', name: 'NSDictionary'),
  BuiltInDeclaration(id: 'c:objc(cs)NSPurgeableData', name: 'NSPurgeableData'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSProtocolChecker',
    name: 'NSProtocolChecker',
  ),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSFileProviderService',
    name: 'NSFileProviderService',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSDimension', name: 'Dimension'),
  BuiltInDeclaration(id: 'c:objc(cs)NSUnit ', name: 'Unit'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSRangeSpecifier ',
    name: 'NSRangeSpecifier',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSQuitCommand', name: 'NSQuitCommand'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSRandomSpecifier',
    name: 'NSRandomSpecifier',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSThread ', name: 'Thread'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSEnergyFormatter',
    name: 'EnergyFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSRecursiveLock', name: 'NSRecursiveLock'),
  BuiltInDeclaration(
    id: 'c:objc(cs)NSRelativeDateTimeFormatter',
    name: 'RelativeDateTimeFormatter',
  ),
  BuiltInDeclaration(id: 'c:objc(cs)NSOperation', name: 'Operation'),
  BuiltInDeclaration(id: 'c:objc(cs)NSBlockOperation ', name: 'BlockOperation'),
  BuiltInDeclaration(id: 'c:objc(cs)NSDeleteCommand', name: 'NSDeleteCommand'),
];
