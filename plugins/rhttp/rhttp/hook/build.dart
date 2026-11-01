import 'dart:io';

import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    await FlutterRustBridgeNativeAssetsBuilder(
      cratePath: 'rust',
      extraCargoEnvironmentVariables: {'RUSTFLAGS': _rustFlags(input)},
    ).run(input: input, output: output);
  });
}

/// http3 needs `reqwest_unstable`. Android arm64/x64 also need 16 KB pages.
///
/// Target fields come from the code-asset build config. Reading them here
/// avoids a direct `code_assets` dependency, which would cap the app at 1.x.
String _rustFlags(BuildInput input) {
  final flags = <String>['--cfg', 'reqwest_unstable'];
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (home != null && home.isNotEmpty) {
    flags.add('--remap-path-prefix=$home/.cargo/=/.cargo/');
  }

  final codeAssets = _codeAssets(input.config.json);
  final targetOs = codeAssets?['target_os'];
  final targetArch = codeAssets?['target_architecture'];
  final needs16kPages =
      targetOs == 'android' && (targetArch == 'arm64' || targetArch == 'x64');
  if (needs16kPages) {
    flags.addAll(const [
      '-C',
      'link-arg=-Wl,--hash-style=both',
      '-C',
      'link-arg=-Wl,-z,max-page-size=16384',
    ]);
  }
  return flags.join(' ');
}

Map<String, Object?>? _codeAssets(Map<String, Object?> config) {
  final extensions = config['extensions'];
  if (extensions is! Map) {
    return null;
  }
  final codeAssets = extensions['code_assets'];
  if (codeAssets is! Map) {
    return null;
  }
  return codeAssets.map((key, value) => MapEntry(key.toString(), value));
}
