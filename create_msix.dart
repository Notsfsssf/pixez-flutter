import 'dart:io';

import 'package:msix/msix.dart';

String requiredEnvironment(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    throw StateError('Missing environment variable: $name');
  }
  return value;
}

Future<void> main() async {
  // Keep passwords out of dart.bat/cmd.exe argument parsing on Windows.
  await Msix([
    '--certificate-path=${requiredEnvironment('CERTIFICATE_PATH')}',
    '--certificate-password=${requiredEnvironment('CERTIFICATE_PASSWORD')}',
    '--publisher=${requiredEnvironment('CERTIFICATE_SUBJECT')}',
    '--version=${requiredEnvironment('MSIX_VERSION')}',
    '--build-windows=false',
    '--output-name=windows-x86_64-release',
  ]).create();
}
