/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

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
