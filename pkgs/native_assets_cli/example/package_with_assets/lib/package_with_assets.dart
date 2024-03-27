import 'package:meta/meta.dart';

@ResourceIdentifier('used_asset')
String someMethod() => 'This is actually called';

@ResourceIdentifier('unused_asset')
String someOtherMethod() => 'This is not called';
