import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pixez/main.dart';

class CopyTextPage extends StatefulWidget {
  const CopyTextPage({Key? key}) : super(key: key);

  @override
  State<CopyTextPage> createState() => _CopyTextPageState();
}

class _CopyTextPageState extends State<CopyTextPage> {
  late TextEditingController _editingController;
  @override
  void initState() {
    _editingController = TextEditingController(text: userSetting.copyInfoText);
    super.initState();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Copy Text'),
        actions: [
          IconButton(
              onPressed: () {
                if (_editingController.text.isEmpty) {
                  return;
                }
                userSetting.setCopyInfoText(_editingController.text);
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: Column(
        children: [
          Center(
            child: TextField(
              controller: _editingController,
            ),
          ),
          Text(
            'Copy to clipboard',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
