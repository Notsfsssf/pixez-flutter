/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';

class SectionCard extends StatefulWidget {
  final List<String> sections;
final String title;
  const SectionCard({Key key,@required this.sections,@required this.title}) : super(key: key);

  @override
  _SectionCardState createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                widget.title,
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
            for (String title in widget.sections)
              CheckboxListTile(
                title: Text(title),

                onChanged: (bool value) {},
                value: false,
              ),
          ],
        ),
      ),
    );
  }
}
