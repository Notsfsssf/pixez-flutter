import 'package:flutter/services.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/lprinter.dart';

class CryptoPlugin {
  static const platform = const MethodChannel('com.perol.dev/crypto');

  static Future<String> getCodeVer() async {
    Constants.code_verifier = await platform.invokeMethod("code_verifier");
    return Constants.code_verifier!;
  }

  static Future<String> getCodeChallenge() async {
    LPrinter.d(Constants.code_verifier);
    return await platform
        .invokeMethod("code_challenge", {"code": Constants.code_verifier});
  }
}
