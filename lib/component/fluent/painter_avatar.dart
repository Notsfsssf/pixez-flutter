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
import 'package:pixez/component/fluent/focus_wrap.dart';
import 'package:pixez/component/fluent/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/fluent/user/users_page.dart';

class PainterAvatar extends StatefulWidget {
  final String url;
  final int id;
  final GestureTapCallback? onTap;
  final Size? size;

  const PainterAvatar(
      {Key? key, required this.url, required this.id, this.onTap, this.size})
      : super(key: key);

  @override
  _PainterAvatarState createState() => _PainterAvatarState();
}

class _PainterAvatarState extends State<PainterAvatar> {
  void pushToUserPage() {
    Leader.push(
      context,
      UsersPage(id: widget.id),
      title: Text(I18n.of(context).painter_id + ': ${widget.id}'),
      icon: Icon(FluentIcons.account_browser),
    );
  }

  _onTap() {
    if (widget.onTap == null)
      pushToUserPage();
    else
      widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return FocusWrap(
      onInvoke: _onTap,
      child: GestureDetector(
        onTap: _onTap,
        child: widget.size == null
            ? SizedBox(
                height: 60,
                width: 60,
                child: CircleAvatar(
                  backgroundImage: PixivProvider.url(
                    widget.url,
                    preUrl: widget.url,
                  ),
                  radius: 100.0,
                  backgroundColor: FluentTheme.of(context).accentColor,
                ),
              )
            : Container(
                height: widget.size!.height,
                width: widget.size!.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: PixivProvider.url(
                      widget.url,
                      preUrl: widget.url,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }
}
