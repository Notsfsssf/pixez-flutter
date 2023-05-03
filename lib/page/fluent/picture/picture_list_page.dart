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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/page/fluent/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';

class PictureListPage extends StatefulWidget {
  final IllustStore store;
  final List<IllustStore> iStores;
  final String? heroString;
  final LightingStore? lightingStore;

  const PictureListPage(
      {Key? key,
      required this.lightingStore,
      required this.store,
      required this.iStores,
      this.heroString})
      : super(key: key);

  @override
  _PictureListPageState createState() => _PictureListPageState();
}

class _PictureListPageState extends State<PictureListPage> {
  late PageController _pageController;
  late int nowPosition;
  late LightingStore? _lightingStore;
  late List<IllustStore> _iStores;
  late IllustStore _store;
  double screenWidth = 0;

  @override
  void initState() {
    _store = widget.store;
    _iStores = widget.iStores;
    _lightingStore = widget.lightingStore;
    nowPosition = _iStores.indexOf(_store);
    _pageController = PageController(initialPage: nowPosition);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width / 2;
    return Stack(
      children: [
        Observer(builder: (_) {
          return PageView.builder(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (index == _iStores.length && _lightingStore != null) {
                return PictureListNextPage(
                  lightingStore: _lightingStore!,
                );
              }
              final f = _iStores[index];
              String? tag = nowPosition == index ? widget.heroString : null;
              return IllustLightingPage(
                id: f.id,
                heroString: tag,
                store: f,
              );
            },
            itemCount: _iStores.length + 1,
          );
        }),
        Container(
          margin: EdgeInsets.all(24),
          child: GestureDetector(
            onHorizontalDragEnd: (DragEndDetails detail) {
              final pixelsPerSecond = detail.velocity.pixelsPerSecond;
              if (pixelsPerSecond.dy.abs() > pixelsPerSecond.dx.abs()) return;
              if (pixelsPerSecond.dx.abs() > screenWidth) {
                int result = nowPosition;
                if (pixelsPerSecond.dx < 0)
                  result++;
                else
                  result--;
                _pageController.animateToPage(result,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut);
                if (result >= _iStores.length) result = _iStores.length - 1;
                if (result < 0) result = 0;
                setState(() {
                  nowPosition = result;
                });
              }
            },
          ),
        )
      ],
    );
  }
}

class PictureListNextPage extends StatefulWidget {
  final LightingStore lightingStore;
  const PictureListNextPage({super.key, required this.lightingStore});

  @override
  State<PictureListNextPage> createState() => _PictureListNextPageState();
}

class _PictureListNextPageState extends State<PictureListNextPage> {
  late LightingStore _lightingStore;
  bool? loadResult;
  @override
  void initState() {
    _lightingStore = widget.lightingStore;
    super.initState();
    _maybeFetch(true);
  }

  _maybeFetch(bool firstIn) async {
    if (_lightingStore.nextUrl == null) return;
    try {
      if (!firstIn) {
        setState(() {
          loadResult = null;
        });
      }
      final result = await _lightingStore.fetchNext();
      if (mounted) {
        setState(() {
          loadResult = result;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_lightingStore.nextUrl == null) {
      return ScaffoldPage(
        header: PageHeader(),
        content: Center(child: Text("No More")),
      );
    }
    if (loadResult == false) {
      return ScaffoldPage(
        header: PageHeader(),
        content: Container(
            child: Center(
          child: Column(children: [
            Text("Load Failed"),
            HyperlinkButton(
                onPressed: () {
                  _maybeFetch(false);
                },
                child: Text("Retry"))
          ]),
        )),
      );
    }
    return ScaffoldPage(
      content: Center(
        child: ProgressRing(),
      ),
    );
  }
}
