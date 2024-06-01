import '../../declarations/compounds/protocol_declaration.dart';
import '../shared/referred_type.dart';

abstract interface class Conformingable {
  abstract List<DeclaredType<ProtocolDeclaration>> conformedProtocols;
}
