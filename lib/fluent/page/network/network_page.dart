import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class NetworkPage extends StatefulWidget {
  final bool? automaticallyImplyLeading;

  const NetworkPage({Key? key, this.automaticallyImplyLeading})
      : super(key: key);

  @override
  _NetworkPageState createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  late TextEditingController _textEditingController;
  bool _isCustom = false;

  @override
  void initState() {
    _textEditingController = TextEditingController(
      text: userSetting.pictureSource,
    );
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Observer(builder: (_) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                I18n.of(context).network,
                style: FluentTheme.of(context).typography.title,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              "tip:如果不能载图，可以尝试切换图床，你可以在设置页重新回到这里",
              textAlign: TextAlign.center,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Observer(builder: (_) {
                return ToggleSwitch(
                    checked: userSetting.disableBypassSni,
                    content: Text(I18n.of(context).disable_sni_bypass),
                    onChanged: (value) async {
                      if (value) {
                        final result = await showDialog(
                          context: context,
                          useRootNavigator: false,
                          builder: (_) {
                            return ContentDialog(
                              title: Text(I18n.of(context).please_note_that),
                              content: Text(
                                I18n.of(context).please_note_that_content,
                              ),
                              actions: <Widget>[
                                Button(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(I18n.of(context).cancel),
                                ),
                                Button(
                                  onPressed: () {
                                    Navigator.of(context).pop('OK');
                                  },
                                  child: Text(I18n.of(context).ok),
                                ),
                              ],
                            );
                          },
                        );
                        if (result != 'OK') return;
                      }

                      userSetting.setDisableBypassSni(value);
                    });
              }),
            )),
            Center(child: Text(I18n.of(context).disable_sni_bypass_message)),
            Center(
              child: Visibility(
                visible: !userSetting.disableBypassSni,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        Text(
                          I18n.of(context).image_site,
                          style: TextStyle(
                              color: FluentTheme.of(context).accentColor),
                        ),
                        IconButton(
                          icon: Icon(FluentIcons.refresh),
                          onPressed: () async {
                            userSetting.setPictureSource(ImageHost);
                            splashStore.setHost(ImageHost);
                            splashStore.helloWord = "= w =";
                            splashStore.maybeFetch();
                          },
                        ),
                        ComboBox(
                          value: _isCustom
                              ? 2
                              : userSetting.pictureSource == ImageHost
                                  ? 0
                                  : userSetting.pictureSource == ImageCatHost
                                      ? 1
                                      : 2,
                          onChanged: (i) => _isCustom = i == 2,
                          items: [
                            ComboBoxItem(
                              child: Text(I18n.of(context).default_title),
                              value: 0,
                              onTap: () {
                                userSetting.setPictureSource(ImageHost);
                                splashStore.setHost(ImageHost);
                                splashStore.helloWord = "= w =";
                                splashStore.maybeFetch();
                                setState(() {
                                  _isCustom = false;
                                });
                              },
                            ),
                            ComboBoxItem(
                              child: Text(ImageCatHost),
                              value: 1,
                              onTap: () {
                                userSetting.setPictureSource(ImageCatHost);
                                splashStore.setHost(ImageCatHost);
                                setState(() {
                                  _isCustom = false;
                                });
                              },
                            ),
                            ComboBoxItem(
                              child: Text('Custom Host'),
                              value: 2,
                              onTap: () {
                                setState(() {
                                  _isCustom = true;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_isCustom)
                          InfoLabel(
                            label: 'Custom Host',
                            child: TextBox(
                              maxLines: 1,
                              placeholder: 'Host',
                              suffix: IconButton(
                                onPressed: () async {
                                  if (_textEditingController.text.isEmpty)
                                    return;
                                  if (_textEditingController.text
                                          .contains("/") ||
                                      _textEditingController.text
                                          .trim()
                                          .contains(" ")) {
                                    displayInfoBar(context,
                                        builder: (context, VoidCallback) =>
                                            InfoBar(
                                              title: Text('illegal'),
                                            ));
                                    return;
                                  }
                                  await userSetting.setPictureSource(
                                      _textEditingController.text.trim());
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                icon: Icon(
                                  FluentIcons.check_mark,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
