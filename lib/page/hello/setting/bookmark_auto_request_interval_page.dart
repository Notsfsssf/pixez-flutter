import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class BookmarkAutoRequestIntervalPage extends StatefulWidget {
  const BookmarkAutoRequestIntervalPage({Key? key}) : super(key: key);

  @override
  State<BookmarkAutoRequestIntervalPage> createState() =>
      _BookmarkAutoRequestIntervalPageState();
}

class _BookmarkAutoRequestIntervalPageState
    extends State<BookmarkAutoRequestIntervalPage> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: userSetting.bookmarkAutoRequestInterval.toString(),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _resetToDefault() async {
    _textEditingController.text = '500';
    await userSetting.setBookmarkAutoRequestInterval(500);
  }

  Future<void> _save() async {
    final value = int.tryParse(_textEditingController.text.trim());
    if (value == null || value <= 0) {
      BotToast.showText(
        text: I18n.of(context).bookmarkAutoRequestIntervalInvalid,
      );
      return;
    }
    await userSetting.setBookmarkAutoRequestInterval(value);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).bookmarkAutoRequestInterval),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefault,
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          TextField(
            controller: _textEditingController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: I18n.of(context).bookmarkAutoRequestInterval,
              helperText: I18n.of(context).bookmarkAutoRequestIntervalHelper,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              title: Text(
                I18n.of(context).bookmarkAutoRequestIntervalWarningTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              subtitle: Text(
                I18n.of(context).bookmarkAutoRequestIntervalWarning,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
