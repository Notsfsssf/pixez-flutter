import 'package:flutter/material.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/shield/shield_page.dart';

class BanPage extends StatefulWidget {
  final String name;

  const BanPage({Key key, @required this.name}) : super(key: key);

  @override
  _BanPageState createState() => _BanPageState();
}

class _BanPageState extends State<BanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'X_X',
                style: TextStyle(fontSize: 26),
              ),
            ),
            Text(I18n.of(context).Shield_message(widget.name)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                child: Text(I18n.of(context).Shielding_settings),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ShieldPage()));
                },
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
