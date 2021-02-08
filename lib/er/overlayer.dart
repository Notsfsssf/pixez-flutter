import 'package:flutter/material.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/page/task/job_page.dart';

class OverLayer {
  static OverlayEntry overlayEntry;
  static bool inserted = false;

  static show(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      if (overlayEntry == null)
        overlayEntry = new OverlayEntry(builder: (context) {
          //外层使用Positioned进行定位，控制在Overlay中的位置
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
