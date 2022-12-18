import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';

class ReportItemsPage extends StatefulWidget {
  final FutureFunc onSubmit;
  const ReportItemsPage({super.key, required this.onSubmit});

  @override
  State<ReportItemsPage> createState() => _ReportItemsPageState();
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
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).report)),
      body: Stack(
        children: [
          ListView.builder(
              itemBuilder: (context, index) {
                final title = items[index];
                return Container(
                  color: index == _selectItem
                      ? Theme.of(context).primaryColor.withOpacity(0.5)
                      : Colors.transparent,
                  child: ListTile(
                    title: Text(title),
                    onTap: () {
                      _selectItem = index;
                    },
                  ),
                );
              },
              itemCount: items.length),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () async {
                BotToast.showLoading();
                await widget.onSubmit();
                BotToast.closeAllLoading();
                Navigator.of(context).pop();
              },
              child: Text("Submit"),
            ),
          )
        ],
      ),
    );
  }
}
