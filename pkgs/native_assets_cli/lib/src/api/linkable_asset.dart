import 'asset.dart';

part '../model/linkable_asset.dart';

/// An asset which can be linked. As the link hook can not add assets, but only
/// modify existing assets, this class provides no public constructor.
sealed class LinkableAsset {
  Uri? get file;
  String get id;
  LinkableAsset withFile(Uri file);
}

/// A [DataAsset] which can be linked, see [LinkableAsset].
abstract class LinkableDataAsset implements LinkableAsset {
  String get name;
}

/// A [NativeCodeAsset] which can be linked, see [LinkableAsset].
abstract class LinkableCodeAsset implements LinkableAsset {}
