import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';

class ReportItemsPage extends StatefulWidget {
  final FutureFunc onSubmit;
  const ReportItemsPage({super.key, required this.onSubmit});

  @override
  State<ReportItemsPage> createState() => _ReportItemsPageState();
}

class Reporter {
  static Future<void> show(BuildContext context, FutureFunc onSubmit) async {
    await Leader.push(
      context,
      ReportItemsPage(onSubmit: onSubmit),
      icon: Icon(FluentIcons.report_document),
      title: Text(I18n.of(context).report),
    );
  }
}

class _ReportItemsPageState extends State<ReportItemsPage> {
  final items = [
    "Sexual Content and Profanity",
    "Hate Speech",
    "Terrorist Content",
    "Dangerous Organizations and Movements",
    "Sensitive Events",
    "Bullying and Harassment",
    "Dangerous Products",
    "Marijuana",
    "Tobacco and Alcohol",
  ]; //政策合规问题，应该不需要翻译，或者说翻译有风险

  var _selectItem = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: Text(I18n.of(context).report)),
      content: Stack(
        children: [
          ListView.builder(
              itemBuilder: (context, index) {
                final title = items[index];
                return Container(
                  color: index == _selectItem
                      ? FluentTheme.of(context).accentColor.withValues(alpha: 255 * 0.5)
                      : Colors.transparent,
                  child: ListTile(
                    title: Text(title),
                    onPressed: () {
                      setState(() {
                        _selectItem = index;
                      });
                    },
                  ),
                );
              },
              itemCount: items.length),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
              child: FilledButton(
                onPressed: () async {
                  BotToast.showLoading();
                  await widget.onSubmit();
                  BotToast.closeAllLoading();
                  Navigator.of(context).pop();
                  BotToast.showText(text: I18n.ofContext().thanks_for_your_feedback);
                },
                child: Text(I18n.ofContext().submit),
              ),
            ),
          )
        ],
      ),
    );
  }
}
