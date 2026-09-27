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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/user/bookmark/tag/bookmark_tag_store.dart';
import 'package:pixez/utils/haptic_util.dart';

class UserBookmarkTagPage extends StatefulWidget {
  final String? currentTag;

  const UserBookmarkTagPage({Key? key, this.currentTag}) : super(key: key);

  @override
  _UserBookmarkTagPageState createState() => _UserBookmarkTagPageState();
}

class _UserBookmarkTagPageState extends State<UserBookmarkTagPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String? currentTag;
  late TextEditingController _tagController;
  String? _suggestedTag;
  late EasyRefreshController _publicRefreshController;
  late EasyRefreshController _privateRefreshController;
  late BookMarkTagStore _publicTagStore;
  late BookMarkTagStore _privateTagStore;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    currentTag = widget.currentTag;
    _tagController = TextEditingController(text: currentTag);
    _publicRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _privateRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    final userId = int.parse(accountStore.now!.userId);
    _publicTagStore = BookMarkTagStore(userId, _publicRefreshController);
    _privateTagStore = BookMarkTagStore(userId, _privateRefreshController);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tagController.dispose();
    _publicRefreshController.dispose();
    _privateRefreshController.dispose();
    super.dispose();
  }

  BookMarkTagStore get _currentTagStore =>
      _tabController.index == 0 ? _publicTagStore : _privateTagStore;

  void _chooseTag(String tag) {
    Navigator.of(context).pop({
      'tag': tag,
      'restrict': _tabController.index == 0 ? 'public' : 'private',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildTabBar(context), elevation: 0.0),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              controller: _tagController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter tag name',
                              ),
                              onSubmitted: (v) {
                                Navigator.of(context).pop({
                                  'tag': v,
                                  'restrict': _tabController.index == 0
                                      ? 'public'
                                      : 'private',
                                });
                              },
                              onChanged: (v) {
                                setState(() {
                                  _suggestedTag = v;
                                });
                              },
                            ),
                          ),
                        ),

                        if (_suggestedTag != null && _suggestedTag!.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _suggestedTag = null;
                                _tagController.clear();
                              });
                            },
                            icon: Icon(Icons.clear),
                          ),
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            final text = _tagController.text.trim();
                            if (text.isEmpty) {
                              return;
                            }

                            Navigator.of(context).pop({
                              'tag': text,
                              'restrict': _tabController.index == 0
                                  ? 'public'
                                  : 'private',
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Observer(
            builder: (_) {
              final query = _tagController.text.trim().toLowerCase();
              final suggestions = _currentTagStore.bookmarkTags
                  .where((tag) => tag.name.toLowerCase().contains(query))
                  .take(8)
                  .toList();
              if (query.isEmpty || suggestions.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: suggestions.length * 48.0,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final tag in suggestions)
                      ListTile(
                        dense: true,
                        title: Text(tag.name),
                        trailing: Text(tag.count.toString()),
                        onTap: () => _chooseTag(tag.name),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NewWidget(
                  restrict: "public",
                  tagStore: _publicTagStore,
                  refreshController: _publicRefreshController,
                ),
                NewWidget(
                  restrict: "private",
                  tagStore: _privateTagStore,
                  refreshController: _privateRefreshController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TabBar _buildTabBar(BuildContext context) {
    return TabBar(
      onTap: (i) {
        HapticUtil.selectionClick();
        setState(() {});
      },
      controller: _tabController,
      tabs: <Widget>[
        Tab(text: I18n.of(context).public),
        Tab(text: I18n.of(context).private),
      ],
    );
  }
}

class NewWidget extends StatefulWidget {
  final String restrict;
  final BookMarkTagStore tagStore;
  final EasyRefreshController refreshController;

  const NewWidget({
    Key? key,
    required this.restrict,
    required this.tagStore,
    required this.refreshController,
  }) : super(key: key);

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  late String restrict;

  @override
  void initState() {
    restrict = widget.restrict;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      widget.tagStore.fetch(restrict);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return EasyRefresh(
          controller: widget.refreshController,
          refreshOnStart: true,
          header: PixezDefault.header(context),
          footer: PixezDefault.footer(context),
          child: ListView(
            children: [
              ListTile(
                title: Text(I18n.of(context).all),
                onTap: () {
                  Navigator.pop(context, {"tag": null, "restrict": restrict});
                },
              ),
              ListTile(
                title: Text(I18n.of(context).unclassified),
                onTap: () {
                  Navigator.pop(context, {
                    "tag": "未分類",
                    "restrict": restrict,
                  }); //日语
                },
              ),
              for (var bookmarkTag in widget.tagStore.bookmarkTags)
                ListTile(
                  title: Text(bookmarkTag.name),
                  trailing: Text(bookmarkTag.count.toString()),
                  onTap: () {
                    Navigator.pop(context, {
                      "tag": bookmarkTag.name,
                      "restrict": restrict,
                    });
                  },
                ),
            ],
          ),
          onRefresh: () async {
            await widget.tagStore.fetch(restrict);
          },
          onLoad: () async {
            await widget.tagStore.next();
          },
        );
      },
    );
  }
}
