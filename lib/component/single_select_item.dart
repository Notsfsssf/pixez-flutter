import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SingleSelectItem extends StatefulWidget {
  final List<String> values;
  final String nowValue;
  const SingleSelectItem({Key key, this.values, this.nowValue})
      : super(key: key);
  @override
  _SingleSelectItemState createState() => _SingleSelectItemState();
}

class _SingleSelectItemState extends State<SingleSelectItem> {
  String _newValue = "";

  Widget _buildItem(String f) => Flexible(
        child: RadioListTile<String>(
          value: f,
          title: Text(f),
          groupValue: _newValue,
          onChanged: (value) {
            setState(() {
              _newValue = value;
            });
          },
        ),
      );
  @override
  void initState() {
    super.initState();
    _newValue = widget.nowValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: widget.values.map((f) {
          return _buildItem(f);
        }),
      ),
    );
  }
}
