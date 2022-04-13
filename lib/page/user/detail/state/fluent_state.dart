import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:pixez/component/fluent_ink_well.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:pixez/page/user/detail/user_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class FluentUserDetailPageState extends UserDetailPageStateBase {
  @override
  Widget build(BuildContext context) {
    var detail = widget.userDetail;
    var profile = widget.userDetail.profile;
    var public = widget.userDetail.profile_publicity;
    // ignore: unnecessary_null_comparison
    return widget.userDetail != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.userDetail.user.comment != null &&
                        widget.userDetail.user.comment!.isNotEmpty
                    ? SelectableHtml(data: widget.userDetail.user.comment!)
                    : SelectableHtml(
                        data: '~',
                      ),
              ),
              InkWell(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(I18n.of(context).nickname),
                      subtitle: SelectableText(detail.user.name),
                    ),
                    TappableListTile(
                        title: Text(I18n.of(context).painter_id),
                        subtitle: SelectableText(detail.user.id.toString()),
                        onTap: () {
                          try {
                            Clipboard.setData(
                                ClipboardData(text: detail.user.id.toString()));
                          } catch (e) {}
                        }),
                    TappableListTile(
                      title: Text(I18n.of(context).total_follow_users),
                      subtitle: SelectableText(
                        detail.profile.total_follow_users.toString(),
                      ),
                      onTap: () {
                        Leader.fluentNav(
                          context,
                          Icon(FluentIcons.user_followed),
                          Text("Follow List"),
                          ScaffoldPage(
                            header: PageHeader(
                              title: Text(I18n.of(context).followed),
                            ),
                            content: FollowList(id: widget.userDetail.user.id),
                          ),
                        );
                      },
                    ),
                    TappableListTile(
                      title: Text(I18n.of(context).total_mypixiv_users),
                      subtitle: SelectableText(
                        detail.profile.total_mypixiv_users.toString(),
                      ),
                      onTap: () {
                        Leader.fluentNav(
                          context,
                          Icon(FluentIcons.user_followed),
                          Text("Follow List"),
                          ScaffoldPage(
                            header: PageHeader(
                              title: Text(I18n.of(context).followed),
                            ),
                            content: FollowList(
                              id: widget.userDetail.user.id,
                              isFollowMe: true,
                            ),
                          ),
                        );
                      },
                    ),
                    TappableListTile(
                      title: Text(I18n.of(context).twitter_account),
                      subtitle: Text(detail.profile.twitter_account ?? ""),
                      onTap: () async {
                        final url = profile.twitter_url;
                        try {
                          await launch(url!);
                        } catch (e) {}
                      },
                    ),
                    ListTile(
                      title: Text(I18n.of(context).gender),
                      subtitle: Text(detail.profile.gender ?? ""),
                    ),
                    ListTile(
                      title: Text(I18n.of(context).job),
                      subtitle: Text(detail.profile.job ?? ""),
                    ),
                    TappableListTile(
                      title: Text('Pawoo'),
                      subtitle: Text(public.pawoo ? 'Link' : 'none'),
                      onTap: () async {
                        if (!public.pawoo) return;
                        var url = detail.profile.pawoo_url;
                        try {
                          await launch(url!);
                        } catch (e) {}
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        : ProgressRing();
  }
}
