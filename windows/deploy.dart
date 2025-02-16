import 'dart:io';

import 'package:msix/msix.dart';

Future<void> main(List<String> arguments) async {
  final release = arguments.contains('--release');
  final manifest = release
      ? 'build\\windows\\x64\\runner\\Release\\AppxManifest.xml'
      : 'build\\windows\\x64\\runner\\Debug\\AppxManifest.xml';

  await Msix([
    if (!release) '--debug',
    '--sign-msix=false',
    ...arguments,
  ]).build();

  print('\r\npackage deploying...');
  final result = await Process.run(
    'powershell.exe',
    [
      '-NoLogo',
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      '{Add-AppxPackage -Path ${manifest} -Register}',
    ],
  );

  if (result.exitCode == 0)
    print('deploy finished.');
  else
    print(result.stderr);
}
