import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/page/picture/picture_page.dart';
import 'package:pixez/page/saucenao/sauce_store.dart';

class SauceNaoPage extends StatefulWidget {
  @override
  _SauceNaoPageState createState() => _SauceNaoPageState();
}

class _SauceNaoPageState extends State<SauceNaoPage> {
  SauceStore _store = SauceStore();

  @override
  void initState() {
    super.initState();
    _store.observableStream.listen((event) {
      if (event != null && _store.results.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PageView(
                  children: _store.results
                      .map((element) => PicturePage(null, element))
                      .toList(),
                )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.youtube_searched_for),
        onPressed: () {
          _store.findImage();
        },
      ),
      appBar: AppBar(),
      body: Container(
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('SauceNao')),
              ),
            ),
            Observer(
                builder: (_) => InkWell(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_store.results.isNotEmpty
                              ? 'tap to show ${_store.results.length} results'
                              : 'Nobody here but us chicken'),
                        ),
                      ),
                      onTap: () {
                        if (_store.results.isNotEmpty) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PageView(
                                    children: _store.results
                                        .map((element) =>
                                            PicturePage(null, element))
                                        .toList(),
                                  )));
                        }
                      },
                    )),
          ],
        ),
      ),
    );
  }
}
