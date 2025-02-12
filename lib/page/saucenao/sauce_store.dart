/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:html/parser.dart' show parse;
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'sauce_store.g.dart';

class SauceStore = SauceStoreBase with _$SauceStore;

abstract class SauceStoreBase with Store {
  static String host = "saucenao.com";
  Dio dio = Dio(BaseOptions(baseUrl: "https://saucenao.com"));
  ObservableList<int> results = ObservableList();
  late StreamController _streamController;
  late ObservableStream observableStream;
  @observable
  bool notStart = true;

  SauceStoreBase() {
    _streamController = StreamController();
    observableStream =
        ObservableStream(_streamController.stream.asBroadcastStream());
  }

  void dispose() async {
    await _streamController.close();
  }

  Future findImage(
      {BuildContext? context, String? path, bool retry = false}) async {
    if (Platform.isAndroid && context != null) {
      final skipAlert = Prefer.getBool("photo_picker_type_selected") ?? false;
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
                              launchUrlString(
                                "https://developer.android.com/training/data-storage/shared/photopicker",
                              );
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
        await Prefer.setBool("photo_picker_type_selected", true);
      }
    }
    notStart = false;
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
      BotToast.showText(text: I18n.ofContext().uploading);

      // if (!userSetting.disableBypassSni) {
      //   final compatibleClient = await RhttpCompatibleClient.create(
      //     settings: userSetting.disableBypassSni
      //         ? null
      //         : ClientSettings(
      //             tlsSettings: TlsSettings(
      //               verifyCertificates: false,
      //               sni: false,
      //             ),
      //             dnsSettings: DnsSettings.dynamic(
      //               resolver: (host) async {
      //                 return ['104.26.14.28'];
      //               },
      //             )),
      //   );
      //   dio.httpClientAdapter = ConversionLayerAdapter(compatibleClient);
      // }
      Response response = await dio.post('/search.php', data: formData);
      BotToast.showText(text: I18n.ofContext().parsing);
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
