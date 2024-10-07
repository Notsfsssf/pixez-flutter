import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

// part 'sauce_notifier.freezed.dart';
// part 'sauce_notifier.g.dart';

// @freezed
// class SauceState with _$SauceState {
//   const factory SauceState({
//     required bool notStart,
//   }) = _SauceState;
// }

@riverpod
class Sauce {
  static String host = "saucenao.com";
  Dio dio = Dio(BaseOptions(
      baseUrl: "https://saucenao.com", headers: {HttpHeaders.hostHeader: host}));
  List<int> results = [];
  late StreamController _streamController;
  late ObservableStream observableStream;

  Sauce() {
    _streamController = StreamController();
    observableStream =
        ObservableStream(_streamController.stream.asBroadcastStream());
  }

  void dispose() async {
    await _streamController.close();
  }

  // SauceState build() {
  //   return SauceState(notStart: true);
  // }

  Future findImage(
      {BuildContext? context, String? path, bool retry = false}) async {
    if (Platform.isAndroid && context != null) {
      final pre = await SharedPreferences.getInstance();
      final skipAlert = pre.getBool("photo_picker_type_selected") ?? false;
      if (!skipAlert) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Observer(
                      builder: (context) {
                        return SwitchListTile(
                          secondary: Icon(Icons.photo_album),
                          onChanged: (bool value) async {
                            await userSetting.setImagePickerType(value ? 1 : 0);
                          },
                          title: InkWell(
                            child: Text(I18n.of(context).photo_picker),
                            onTap: () {
                              launch(
                                  "https://developer.android.com/training/data-storage/shared/photopicker");
                            },
                          ),
                          subtitle:
                              Text(I18n.of(context).photo_picker_subtitle),
                          value: userSetting.imagePickerType == 1,
                        );
                      },
                    ),
                    Divider(),
                    InkWell(
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(I18n.of(context).ok),
                      )),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              );
            });
        await pre.setBool("photo_picker_type_selected", true);
      }
    }
    // state = state.copyWith(notStart: false);
    results.clear();
    final picker = ImagePicker();
    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker =
          userSetting.imagePickerType == 1;
    }
    if (path == null) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      Uint8List originImageBytes = await pickedFile.readAsBytes();
      var newImageBytes = compressImage(originImageBytes);
      LPrinter.d(
          "Uncompressed image size: ${originImageBytes.length}, compressed image size: ${newImageBytes.length}");
      path =
          "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
      await File(path).writeAsBytes(newImageBytes);
    }
    var formData = FormData();
    formData.files.addAll([
      MapEntry("file", await MultipartFile.fromFile(path)),
    ]);
    try {
      BotToast.showText(text: "uploading");
      if (userSetting.disableBypassSni) {
        dio.options.baseUrl = "https://$host";
      } else {
        dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
          HttpClient httpClient = HttpClient();
          httpClient.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return httpClient;
        });
      }
      Response response = await dio.post('/search.php', data: formData);
      BotToast.showText(text: "parsing");
      var document = parse(response.data);
      document.querySelectorAll('a').forEach((element) {
        var link = element.attributes['href'];
        if (link != null) {
          bool need = link.startsWith('https://www.pixiv.net') &&
              link.contains('illust_id');
          if (need) {
            var result = Uri.parse(link).queryParameters['illust_id'];
            if (result != null) {
              try {
                results.add(int.parse(result));
              } catch (e) {}
            }
          }
        }
      });
      _streamController.add(1);
    } catch (e) {
      BotToast.showText(text: "error${e}");
    }
  }

  Uint8List compressImage(Uint8List originImageBytes) {
    var originImage = decodeImage(originImageBytes);
    var originWidth = originImage!.width;
    var originHeight = originImage.height;
    int newWidth, newHeight;
    if (originWidth < 720 || originHeight < 720) {
      newWidth = originWidth;
      newHeight = originHeight;
    } else if (originWidth > originHeight) {
      newHeight = 720;
      newWidth = originWidth * newHeight ~/ originHeight;
    } else {
      newWidth = 720;
      newHeight = originHeight * newWidth ~/ originWidth;
    }
    var newImage = copyResize(originImage, width: newWidth, height: newHeight);
    return encodeJpg(newImage, quality: 75);
  }
}
