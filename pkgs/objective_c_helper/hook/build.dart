import 'dart:io';

/// Build hook for objective_c_helper.
///
/// The native C compilation is only required on macOS.
/// On other platforms (e.g. Windows, Linux), this hook is intentionally skipped.
/// macOS CI will handle the actual native compilation.
Future<void> main(List<String> args) async {
  if (!Platform.isMacOS) {
    print('objective_c_helper build hook skipped (non-macOS platform).');
    return;
  }

  print(
    'objective_c_helper build hook: native compilation will run on macOS CI.',
  );
}
