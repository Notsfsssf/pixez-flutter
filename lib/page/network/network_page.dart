import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
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
  late bool _automaticallyImplyLeading;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController(
      text: userSetting.pictureSource,
    );
    _automaticallyImplyLeading = widget.automaticallyImplyLeading ?? false;
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                automaticallyImplyLeading: _automaticallyImplyLeading,
                elevation: 0.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  I18n.of(context).network,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  I18n.of(context).network_tip,
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildNetworkModeSetting(context),
              ),
              Visibility(
                visible: userSetting.networkMode.allowsImageSource,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            I18n.of(context).image_site,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.refresh_outlined),
                            onPressed: () async {
                              userSetting.setPictureSource(ImageHost);
                              splashStore.setHost(ImageHost);
                              splashStore.helloWord = "= w =";
                              splashStore.maybeFetch();
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            I18n.of(context).default_title,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                          ),
                          selected: userSetting.pictureSource == ImageHost,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          onTap: () async {
                            userSetting.setPictureSource(ImageHost);
                            splashStore.setHost(ImageHost);
                            splashStore.helloWord = "= w =";
                            splashStore.maybeFetch();
                          },
                        ),
                        ListTile(
                          title: Text(
                            ImageCatHost,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                          ),
                          selected: userSetting.pictureSource == ImageCatHost,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          onTap: () async {
                            userSetting.setPictureSource(ImageCatHost);
                            splashStore.setHost(ImageCatHost);
                          },
                        ),
                        ListTile(
                          selected:
                              userSetting.pictureSource != ImageHost &&
                              userSetting.pictureSource != ImageCatHost,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          title: Theme(
                            data: Theme.of(context).copyWith(
                              primaryColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                            ),
                            child: TextField(
                              maxLines: 1,
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                hintText: 'Host',
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (_textEditingController.text.isEmpty)
                                      return;
                                    if (_textEditingController.text
                                        .trim()
                                        .contains(" ")) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("illegal"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    final host = _textEditingController.text
                                        .trim();
                                    await userSetting.setPictureSource(host);
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                  icon: Icon(Icons.check, color: Colors.black),
                                ),
                                labelText: I18n.of(context).custom_host,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNetworkModeSetting(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(title: Text(I18n.of(context).network_mode)),
          RadioGroup<NetworkMode>(
            groupValue: userSetting.networkMode,
            onChanged: (value) async {
              if (value == null) return;
              await userSetting.setNetworkMode(value);
            },
            child: Column(
              children: NetworkMode.values.map((mode) {
                return RadioListTile<NetworkMode>(
                  value: mode,
                  title: Text(_networkModeTitle(context, mode)),
                  subtitle: Text(_networkModeMessage(context, mode)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
