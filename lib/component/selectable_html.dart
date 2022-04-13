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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/selectable_html/fluent_state.dart';
import 'package:pixez/component/selectable_html/material_state.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/supportor_plugin.dart';

class SelectableHtml extends StatefulWidget {
  final String data;

  const SelectableHtml({Key? key, required this.data}) : super(key: key);

  @override
  SelectableHtmlStateBase createState() {
    if (Constants.isFluentUI)
      return FluentSelectableHtmlState();
    else
      return MaterialSelectableHtmlState();
  }
}

abstract class SelectableHtmlStateBase extends State<SelectableHtml> {
  bool l = false;

  @override
  void initState() {
    super.initState();

    initMethod();
  }

  bool supportTranslate = false;
  Future<void> initMethod() async {
    if (!Platform.isAndroid) return;
    bool results = await SupportorPlugin.processText();
    setState(() {
      supportTranslate = results;
    });
  }
}
