import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/network_mode.dart';

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
            _buildNetworkModeSetting(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkModeSetting(BuildContext context) {
    final widget = Expander(
      initiallyExpanded: true,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(I18n.of(context).network_mode),
          const SizedBox(height: 8),
          RadioGroup<NetworkMode>(
            groupValue: userSetting.networkMode,
            onChanged: (value) async {
              if (value == null) return;
              await userSetting.setNetworkMode(value);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: NetworkMode.values.map((mode) {
                return RadioButton<NetworkMode>(
                  value: mode,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_networkModeTitle(context, mode)),
                      Text(
                        _networkModeMessage(context, mode),
                        style: FluentTheme.of(context).typography.caption,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      content: userSetting.networkMode.allowsImageSource
          ? Column(
              children: [
                ListTile(
                  title: Text(
                    I18n.of(context).image_site,
                    style: TextStyle(
                      color: FluentTheme.of(context).accentColor,
                    ),
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
                      final host = _textEditingController.text.trim();
                      await userSetting.setPictureSource(host);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    icon: Icon(FluentIcons.check_mark),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
    return widget;
  }

  String _networkModeTitle(BuildContext context, NetworkMode mode) {
    switch (mode) {
      case NetworkMode.compat:
        return I18n.of(context).network_mode_compat;
      case NetworkMode.ech:
        return I18n.of(context).network_mode_ech;
      case NetworkMode.standard:
        return I18n.of(context).network_mode_standard;
    }
  }

  String _networkModeMessage(BuildContext context, NetworkMode mode) {
    switch (mode) {
      case NetworkMode.compat:
        return 'bypass sni,doh';
      case NetworkMode.ech:
        return 'ech';
      case NetworkMode.standard:
        return 'standard';
    }
  }
}
