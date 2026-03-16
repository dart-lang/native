import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      print(
        'buildCodeAssets is false, skipping Android system library inclusion.',
      );
      return;
    }
    final targetOs = input.config.code.targetOS;
    if (targetOs != OS.android) {
      print(
        'Target OS is $targetOs, skipping Android system library inclusion.',
      );
      return;
    }
    print('Adding libc++_shared.so from Android system libraries...');
    final temp = await resolveAndroidSystemLibPath(
      input.config.code,
      Logger('AndroidLibcppSharedHook')
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.message}');
        }),
    );
    print('Resolved Android system library path: $temp');
    final androidLibDir = await resolveAndroidSystemLibPath(
      input.config.code,
      Logger('AndroidLibcppSharedHook')
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.message}');
        }),
    );
    final libcppSharedPath = androidLibDir.resolve('libc++_shared.so');
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'libc++_shared.so',
        file: libcppSharedPath,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  });
}
