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
import 'package:pixez/er/leader.dart';
import 'package:pixez/page/task/job_page.dart';

class OverLayer {
  static OverlayEntry overlayEntry;
  static bool inserted = false;

  static show(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      return;//
      if (overlayEntry == null)
        overlayEntry = new OverlayEntry(builder: (context) {
          return new Positioned(
              top: MediaQuery.of(context).size.height * 0.7,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      Leader.push(context, JobPage());
                    },
                    child: Center(
                      child: Card(
                        shape: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.download_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
              ));
        });
      if (!inserted) {
        Overlay.of(context).insert(overlayEntry);
        inserted = true;
      }
    });
  }

  static hide() {
    overlayEntry.remove();
    inserted = false;
  }
}
