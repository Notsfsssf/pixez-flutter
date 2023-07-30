import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class SaveEffectTrailing extends StatelessWidget {
  const SaveEffectTrailing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return ToggleSwitch(
        content: Text(I18n.of(context).save_effect),
        checked: userSetting.saveEffectEnable,
        onChanged: (bool value) {
          userSetting.saveEffectEnable = value;
        },
      );
    });
  }
}
