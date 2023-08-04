
part of 'windows.dart';

class Paths {
  static MethodChannel channel = MethodChannel("com.perol.dev/single_instance");

  static Future<String?> getAppDataFolderPath() async {
    try {
      return await channel.invokeMethod("getAppDataFolderPath");
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getPicturesFolderPath() async {
    try {
      return await channel.invokeMethod("getPicturesFolderPath");
    } catch (e) {
      return null;
    }
  }
}
