import 'package:data_assets/data_assets.dart';
import 'package:fun_with_flags/src/hook.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) {
  link(args, (input, output) async {
    final usedFlags = input.metadata
        .where((asset) => asset.key.startsWith(prefix))
        .expand((e) => e.value as List<String>)
        .map((country) => 'assets/$country.txt');

    final usedFlagAssets = input.assets.data.where(
      (flagAsset) => usedFlags.contains(flagAsset.id),
    );
    output.assets.data.addAll(usedFlagAssets);
  });
}
