import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class NetworkSelectPage extends StatefulWidget {
  @override
  _NetworkSelectPageState createState() => _NetworkSelectPageState();
}

class _NetworkSelectPageState extends State<NetworkSelectPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
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
              Container(
                height: 24,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ToggleSwitch(
                    checked: userSetting.disableBypassSni,
                    onChanged: (v) async =>
                        await userSetting.setDisableBypassSni(v),
                    content: userSetting.disableBypassSni
                        ? const Text("Nope")
                        : const Text("Yes"),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
