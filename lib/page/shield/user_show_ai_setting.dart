import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/show_ai_response.dart';
import 'package:pixez/network/api_client.dart';

class UserShowAISetting extends StatefulWidget {
  final bool showAI;

  const UserShowAISetting({Key? key, required this.showAI}) : super(key: key);

  @override
  State<UserShowAISetting> createState() => _UserShowAISettingState();
}

class _UserShowAISettingState extends State<UserShowAISetting> {
  bool _showAI = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _showAI = widget.showAI;
    });
  }

  _changeShowAI(bool value) async {
    try {
      BotToast.showLoading();
      Response response = await apiClient.postUserAIShowSettings(value);
      var showAIResponse = ShowAIResponse.fromJson(response.data);
      if (mounted) {
        setState(() {
          _showAI = showAIResponse.showAI;
        });
      }
    } catch (e) {
    } finally {
      BotToast.closeAllLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).ai_work_display_settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(I18n.of(context).show),
            trailing: !_showAI ? null : Icon(Icons.check),
            onTap: () {
              if (!_showAI) {
                _changeShowAI(true);
              }
            },
          ),
          ListTile(
            title: Text(I18n.of(context).partially_hidden),
            trailing: _showAI ? null : Icon(Icons.check),
            onTap: () {
              if (_showAI) {
                _changeShowAI(false);
              }
            },
          ),
        ],
      ),
    );
  }
}
