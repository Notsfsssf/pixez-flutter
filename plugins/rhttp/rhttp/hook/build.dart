import 'dart:io';

import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    await FlutterRustBridgeNativeAssetsBuilder(
      cratePath: 'rust',
      extraCargoEnvironmentVariables: _cargoEnvironment(input),
    ).run(input: input, output: output);
  });
}

/// http3 needs `reqwest_unstable`. Android arm64/x64 also need 16 KB pages.
///
/// iOS: rustc defaults to 10.0; C deps (aws-lc/zstd) need >=13 for
/// `___chkstk_darwin`. Native Assets does not inherit Xcode's
/// IPHONEOS_DEPLOYMENT_TARGET (unlike Cargokit), so pin it here.
/// Matches Runner's 15.0. Drop when native_toolchain_rust forwards
/// code_assets.ios.target_version automatically.
Map<String, String> _cargoEnvironment(BuildInput input) {
  final codeAssets = _codeAssets(input.config.json);
  final targetOs = codeAssets?['target_os'];
  final targetArch = codeAssets?['target_architecture'];

  final env = <String, String>{
    'RUSTFLAGS': _rustFlags(
      targetOs: targetOs,
      targetArch: targetArch,
    ),
  };

  if (targetOs == 'ios') {
    const version = '15.0';
    env['IPHONEOS_DEPLOYMENT_TARGET'] = version;
    env['IPHONESIMULATOR_DEPLOYMENT_TARGET'] = version;
  }

  return env;
}

String _rustFlags({Object? targetOs, Object? targetArch}) {
  final flags = <String>['--cfg', 'reqwest_unstable'];
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (home != null && home.isNotEmpty) {
    flags.add('--remap-path-prefix=$home/.cargo/=/.cargo/');
  }

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
  if (extensions is! Map) return null;
  final codeAssets = extensions['code_assets'];
  if (codeAssets is! Map) return null;
  return codeAssets.map((key, value) => MapEntry(key.toString(), value));
}
