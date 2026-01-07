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
      content: Observer(
        builder: (context) => Column(
          children: [
            ListTile(title: Text(I18n.of(context).network_tip)),
            _buildSNISetting(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSNISetting(BuildContext context) {
    Widget widget = ListTile(
      title: Text(I18n.of(context).disable_sni_bypass),
      subtitle: Text(I18n.of(context).disable_sni_bypass_message),
      trailing: ToggleSwitch(
        checked: userSetting.disableBypassSni,
        onChanged: (value) async {
          if (value == true) {
            final result = await showDialog(
              context: context,
              useRootNavigator: false,
              builder: (_) => ContentDialog(
                title: Text(I18n.of(context).please_note_that),
                content: Text(I18n.of(context).please_note_that_content),
                actions: <Widget>[
                  Button(
                    onPressed: Navigator.of(context).pop,
                    child: Text(I18n.of(context).cancel),
                  ),
                  FilledButton(
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
    );
    if (!userSetting.disableBypassSni) {
      widget = Expander(
        initiallyExpanded: true,
        header: widget,
        content: Column(
          children: [
            ListTile(
              title: Text(
                I18n.of(context).image_site,
                style: TextStyle(color: FluentTheme.of(context).accentColor),
              ),
              trailing: IconButton(
                icon: Icon(FluentIcons.refresh),
                onPressed: () async {
                  userSetting.setPictureSource(ImageHost);
                  splashStore.setHost(ImageHost);
                  splashStore.helloWord = "= w =";
                  splashStore.maybeFetch();
                },
              ),
            ),
            ListTile.selectable(
              title: Text(I18n.of(context).default_title),
              selected: userSetting.pictureSource == ImageHost,
              onSelectionChange: (value) async {
                userSetting.setPictureSource(ImageHost);
                splashStore.setHost(ImageHost);
                splashStore.helloWord = "= w =";
                splashStore.maybeFetch();
              },
            ),
            ListTile.selectable(
              title: Text(ImageCatHost),
              selected: userSetting.pictureSource == ImageCatHost,
              onSelectionChange: (value) async {
                await userSetting.setPictureSource(ImageCatHost);
                splashStore.setHost(ImageCatHost);
                splashStore.helloWord = "= w =";
                splashStore.maybeFetch();
              },
            ),
            ListTile.selectable(
              leading: Text(I18n.of(context).custom_host),
              selected:
                  userSetting.pictureSource != ImageHost &&
                  userSetting.pictureSource != ImageCatHost,
              title: TextBox(
                maxLines: 1,
                placeholder: 'Host',
                controller: _textEditingController,
              ),
              trailing: IconButton(
                onPressed: () async {
                  if (_textEditingController.text.isEmpty) return;
                  if (_textEditingController.text.trim().contains(" ")) {
                    displayInfoBar(
                      context,
                      builder: (context, VoidCallback) =>
                          InfoBar(title: Text('illegal')),
                    );
                    return;
                  }
                  await userSetting.setPictureSource(
                    _textEditingController.text.trim(),
                  );
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                icon: Icon(FluentIcons.check_mark),
              ),
            ),
          ],
        ),
      );
    }
    return widget;
  }
}
