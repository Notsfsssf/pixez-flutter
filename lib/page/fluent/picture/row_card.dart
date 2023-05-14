import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluentui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/fluent/search/result_page.dart';

class RowCard extends StatelessWidget {
  final _flyoutController = FlyoutController();
  final _flyoutKey = GlobalKey();
  final Tags f;
  RowCard(this.f);

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      key: _flyoutKey,
      controller: _flyoutController,
      child: GestureDetector(
        onTap: () {
          Leader.push(
            context,
            ResultPage(
              word: f.name,
              translatedName: f.translatedName ?? "",
            ),
            icon: Icon(FluentIcons.show_results),
            title: Text(I18n.of(context).tag + ' #${f.name}'),
          );
        },
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "#${f.name}",
                children: [
                  TextSpan(
                    text: " ",
                    style: FluentTheme.of(context).typography.caption,
                  ),
                  TextSpan(
                      text: "${f.translatedName ?? "~"}",
                      style: FluentTheme.of(context).typography.caption)
                ],
                style: FluentTheme.of(context)
                    .typography
                    .caption!
                    .copyWith(color: FluentTheme.of(context).accentColor))),
        onSecondaryTapUp: (details) => _flyoutController.showFlyout(
          position: getPosition(context, _flyoutKey, details),
          barrierColor: Colors.black.withOpacity(0.1),
          builder: (context) => MenuFlyout(
            color: Colors.transparent,
            items: [
              MenuFlyoutItem(
                text: Text(I18n.of(context).ban),
                onPressed: () async {
                  await muteStore.insertBanTag(BanTagPersist(
                    name: f.name,
                    translateName: f.translatedName ?? "",
                  ));
                  Navigator.of(context).pop();
                },
              ),
              MenuFlyoutItem(
                text: Text(I18n.of(context).bookmark),
                onPressed: () async {
                  await bookTagStore.bookTag(f.name);
                  Navigator.of(context).pop();
                },
              ),
              MenuFlyoutItem(
                text: Text(I18n.of(context).copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: f.name));
                  showSnackbar(
                      context,
                      Snackbar(
                        content: Text(I18n.of(context).copied_to_clipboard),
                      ));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
