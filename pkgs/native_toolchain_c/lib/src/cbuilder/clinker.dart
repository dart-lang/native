part of 'cbuilder.dart';

class CLinker {
  final CBuilder _cbuilder;

  CLinker({
    required String name,
    required String assetName,
    List<String> sources = const [],
    List<String> includes = const [],
    List<String> dartBuildFiles = const ['hook/link.dart'],
    @visibleForTesting Uri? installName,
    List<String> flags = const [],
    Map<String, String?> defines = const {},
    bool pic = true,
    String? std,
    Language language = Language.c,
    String? cppLinkStdLib,
    required LinkerOptions linkerOptions,
  }) : _cbuilder = CBuilder._(
          name: name,
          assetName: assetName,
          dartBuildFiles: dartBuildFiles,
          sources: sources,
          includes: includes,
          installName: installName,
          flags: flags,
          defines: defines,
          pic: pic,
          std: std,
          buildModeDefine: false,
          ndebugDefine: false,
          language: language,
          cppLinkStdLib: cppLinkStdLib,
          type: _CBuilderType.library,
          linkerOptions: linkerOptions,
        );

  Future<void> run({
    required LinkConfig linkConfig,
    required LinkOutput linkOutput,
    required Logger? logger,
  }) async {
    final buildOutput = BuildOutput();

    final linkMode = DynamicLoadingBundled();
    final libraryFileName =
        linkConfig.targetOS.libraryFileName(_cbuilder.name, linkMode);
    final libUri = linkConfig.outputDirectory.resolve(libraryFileName);
    await _cbuilder._run(
      linkConfig,
      logger,
      buildOutput,
      linkMode,
      libUri,
    );
    linkOutput.addAsset(NativeCodeAsset(
      package: linkConfig.packageName,
      name: _cbuilder.assetName!,
      linkMode: linkMode,
      os: linkConfig.targetOS,
      architecture: linkConfig.dryRun ? null : linkConfig.targetArchitecture,
      file: libUri,
    ));
  }
}
