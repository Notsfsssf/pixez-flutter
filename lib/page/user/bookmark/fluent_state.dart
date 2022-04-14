import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/component/fluent/fluent_ink_well.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/bookmark/tag/user_bookmark_tag_page.dart';

class FluentBookmarkPageState extends BookmarkPageStateBase {
  Widget buildTopChip(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SortGroup(
            children: [I18n.of(context).public, I18n.of(context).private],
            onChange: (index) {
              if (index == 0)
                setState(() {
                  futureGet = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                          widget.id, restrict = 'public', null));
                });
              if (index == 1)
                setState(() {
                  futureGet = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                          widget.id, restrict = 'private', null));
                });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                // TODO: Leader.fluentNav 或改为对话框
                final result = await Navigator.of(context).push(
                    FluentPageRoute(builder: (_) => UserBookmarkTagPage()));
                if (result != null) {
                  String? tag = result['tag'];
                  String restrict = result['restrict'];
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (bool e) => apiClient.getBookmarksIllust(
                            widget.id, restrict, tag));
                  });
                }
              },
              child: Chip(
                image: Icon(FluentIcons.sort),
                // backgroundColor: Theme.of(context).cardColor,
                // elevation: 4.0,
                // padding: EdgeInsets.all(0.0),
              ),
              mode: InkWellMode.focusBorderOnly,
            ),
          ),
        ],
      ),
    );
  }
}
