import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/network_mode.dart';

class NetworkSelectPage extends StatefulWidget {
  @override
  _NetworkSelectPageState createState() => _NetworkSelectPageState();
}

class _NetworkSelectPageState extends State<NetworkSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return ScaffoldPage(
          content: SafeArea(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    I18n.of(context).network_question,
                    style: FluentTheme.of(context).typography.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
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
                                    style: FluentTheme.of(
                                      context,
                                    ).typography.caption,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
