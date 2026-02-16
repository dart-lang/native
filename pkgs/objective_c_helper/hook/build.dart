import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final builder = CBuilder.library(
      name: 'objective_c_helper',
      assetName: 'objective_c_helper.dart',
      sources: ['lib/src/util.c'],
    );

    await builder.run(input: input, output: output);
  });
}
