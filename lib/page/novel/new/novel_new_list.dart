

import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelNewList extends StatefulWidget {
  const NovelNewList({super.key});

  @override
  State<NovelNewList> createState() => _NovelNewListState();
}

class _NovelNewListState extends State<NovelNewList> {
  late FutureGet futureGet;
  @override
  void initState() {
    futureGet = () => apiClient.getNovelFollow('public');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16.0))),
                    builder: (context) {
                      return SafeArea(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(I18n.of(context).public),
                            onTap: () {
                              setState(() {
                                futureGet =
                                    () => apiClient.getNovelFollow('public');
                              });
                            },
                          ),
                          ListTile(
                              title: Text(I18n.of(context).private),
                              onTap: () {
                                setState(() {
                                  futureGet =
                                      () => apiClient.getNovelFollow('private');
                                });
                              }),
                        ],
                      ));
                    });
              }),
        ),
        Expanded(
          child: NovelLightingList(
            futureGet: futureGet,
          ),
        ),
      ]),
    );
  }
}