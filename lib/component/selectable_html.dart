import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share/share.dart';

class SelectableHtml extends StatefulWidget {
  final String data;

  const SelectableHtml({Key key, @required this.data}) : super(key: key);

  @override
  _SelectableHtmlState createState() => _SelectableHtmlState();
}

class _SelectableHtmlState extends State<SelectableHtml> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        final result = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("长按复制"),
                content: SelectableText(widget.data ?? ""),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop("OK");
                    },
                  )
                ],
              );
            });
      },
      child: Html(
        data: widget.data,
        onLinkTap: (String url) {
          Share.share(url);
        },
      ),
    );
  }
}
