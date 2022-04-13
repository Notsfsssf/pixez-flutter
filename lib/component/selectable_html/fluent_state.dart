import 'dart:io';

import 'package:extended_text/extended_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/component/text_selection_toolbar.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/component/fluent_ink_well.dart';
import 'package:pixez/main.dart';
import 'package:pixez/supportor_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class FluentSelectableHtmlState extends SelectableHtmlStateBase {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          l = true;
        });
      },
      child: l
          ? Container(
              child: Column(
                children: [
                  if (Platform.isAndroid)
                    ExtendedText(
                      (widget.data).toTranslateText(),
                      style: FluentTheme.of(context).typography.body,
                      selectionEnabled: true,
                      selectionControls: TranslateTextSelectionControls(),
                    )
                  else
                    ExtendedText(
                      (widget.data).toTranslateText(),
                      style: FluentTheme.of(context).typography.body,
                      selectionEnabled: true,
                    ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (supportTranslate)
                        IconButton(
                          icon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(FluentIcons.translate),
                          ),
                          onPressed: () {
                            SupportorPlugin.start(
                                (widget.data).toTranslateText());
                          },
                        ),
                      IconButton(
                          icon: Icon(FluentIcons.chrome_close),
                          onPressed: () {
                            setState(() {
                              l = false;
                            });
                          })
                    ],
                  )
                ],
              ),
            )
          : HtmlWidget(
              widget.data,
              customStylesBuilder: (e) {
                if (e.attributes.containsKey('href')) {
                  final color = userSetting.themeData.colorScheme.primary;
                  return {
                    'color': '#${color.value.toRadixString(16).substring(2, 8)}'
                  };
                }
                return null;
              },
              onTapUrl: (String url) async {
                try {
                  if (url.startsWith("pixiv")) {
                    Leader.pushWithUri(context, Uri.parse(url));
                  } else
                    await launch(url);
                } catch (e) {
                  Share.share(url);
                }
                return true;
              },
            ),
    );
  }
}
