import 'package:flutter/material.dart';
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
        return Scaffold(
          body: SafeArea(
            child: ListView(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  elevation: 0.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    I18n.of(context).network_question,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: RadioGroup<NetworkMode>(
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
