import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';

class NetworkPage extends StatefulWidget {
  @override
  _NetworkPageState createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    Platform.isIOS ? HelloPage() : AndroidHelloPage()),
            (route) => route == null,
          );
        },
      ),
      body: Observer(builder: (_) {
        return ListView(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              elevation: 0.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Observer(builder: (_) {
                  return SwitchListTile(
                      value: userSetting.disableBypassSni,
                      activeColor: Theme.of(context).accentColor,
                      title: Text(I18n.of(context).disable_sni_bypass),
                      subtitle:
                          Text(I18n.of(context).disable_sni_bypass_message),
                      onChanged: (value) async {
                        if (value) {
                          final result = await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title:
                                      Text(I18n.of(context).please_note_that),
                                  content: Text(I18n.of(context)
                                      .please_note_that_content),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(I18n.of(context).cancel)),
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop('OK');
                                        },
                                        child: Text(I18n.of(context).ok)),
                                  ],
                                );
                              });
                          if (result == 'OK') {
                            userSetting.setDisableBypassSni(value);
                          }
                        } else {
                          userSetting.setDisableBypassSni(value);
                        }
                      });
                }),
              ),
            ),
            Visibility(
              visible: !userSetting.disableBypassSni,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(I18n.of(context).image_site),
                        trailing: IconButton(
                          icon: Icon(Icons.refresh_outlined),
                          onPressed: () async {
                            userSetting.setPictureSource(ImageHost);
                            splashStore.setHost(ImageCatHost);
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(I18n.of(context).default_title),
                        selected: userSetting.pictureSource == ImageHost,
                        selectedTileColor: Theme.of(context).accentColor,
                        onTap: () async {
                          userSetting.setPictureSource(ImageHost);
                          splashStore.setHost(ImageCatHost);
                        },
                      ),
                      ListTile(
                        title: Text(ImageCatHost),
                        selected: userSetting.pictureSource == ImageCatHost,
                        selectedTileColor: Theme.of(context).accentColor,
                        onTap: () async {
                          userSetting.setPictureSource(ImageCatHost);
                          splashStore.setHost(ImageCatHost);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
