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
      header: PageHeader(title: Text(I18n.of(context).network)),
      content: Center(
        child: Observer(
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // todo i18n
                "tip:如果不能载图，可以尝试切换图床，你可以在设置页重新回到这里",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Observer(
                builder: (_) => Checkbox(
                  checked: userSetting.disableBypassSni,
                  content: Text(I18n.of(context).disable_sni_bypass),
                  onChanged: (value) async {
                    if (value == true) {
                      final result = await showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (_) => ContentDialog(
                          title: Text(I18n.of(context).please_note_that),
                          content:
                              Text(I18n.of(context).please_note_that_content),
                          actions: <Widget>[
                            Button(
                              onPressed: Navigator.of(context).pop,
                              child: Text(I18n.of(context).cancel),
                            ),
                            Button(
                              onPressed: () => Navigator.of(context).pop('OK'),
                              child: Text(I18n.of(context).ok),
                            ),
                          ],
                        ),
                      );
                      if (result != 'OK') return;
                    }
                    userSetting.setDisableBypassSni(value == true);
                  },
                ),
              ),
              Text(I18n.of(context).disable_sni_bypass_message),
              const SizedBox(height: 10),
              Visibility(
                visible: !userSetting.disableBypassSni,
                child: Card(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
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
                        )
                      ]),
                      SizedBox(height: 10),
                      RadioButton(
                        checked: userSetting.pictureSource == ImageHost,
                        onChanged: (value) async {
                          await userSetting.setPictureSource(ImageHost);
                          splashStore.setHost(ImageHost);
                          splashStore.helloWord = "= w =";
                          splashStore.maybeFetch();
                        },
                        content: Text(I18n.of(context).default_title),
                      ),
                      SizedBox(height: 10),
                      RadioButton(
                        checked: userSetting.pictureSource == ImageCatHost,
                        onChanged: (value) async {
                          await userSetting.setPictureSource(ImageCatHost);
                          splashStore.setHost(ImageCatHost);
                        },
                        content: Text(ImageCatHost),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Custom Host'),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 300,
                            child: TextBox(
                              maxLines: 1,
                              placeholder: 'Host',
                              controller: _textEditingController,
                              suffix: IconButton(
                                onPressed: () async {
                                  if (_textEditingController.text.isEmpty)
                                    return;
                                  if (_textEditingController.text
                                      .trim()
                                      .contains(" ")) {
                                    displayInfoBar(context,
                                        builder: (context, VoidCallback) =>
                                            InfoBar(title: Text('illegal')));
                                    return;
                                  }
                                  await userSetting.setPictureSource(
                                      _textEditingController.text.trim());
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                icon: Icon(FluentIcons.check_mark),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
