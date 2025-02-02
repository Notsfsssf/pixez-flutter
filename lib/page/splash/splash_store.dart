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

import 'package:mobx/mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/onezero_response.dart';

part 'splash_store.g.dart';

class SplashStore = _SplashStoreBase with _$SplashStore;

abstract class _SplashStoreBase with Store {
  final String OK_TEXT = '♪^∀^●)ノ';
  @observable
  String helloWord = "= w =";
  String host = ImageHost;
  @observable
  OnezeroResponse? onezeroResponse;

  _SplashStoreBase();

  @action
  hello() async {
    maybeFetch();
    Future.delayed(Duration(seconds: 2), () {
      helloWord = 'w(ﾟДﾟ)w';
    });
  }

  maybeFetch() async {
    if (userSetting.disableBypassSni || helloWord == OK_TEXT) return;
    fetch();
  }

  @action
  fetch() async {
    if (helloWord == OK_TEXT ||
        host != ImageHost ||
        userSetting.pictureSource != ImageHost) return;
    try {
      await Hoster.dnsQueryAll();
    } catch (e) {}
    this.host = Hoster.iPximgNet();
    helloWord = OK_TEXT;
  }

  setHost(String value) {
    host = value;
    if (host == ImageHost) {
      helloWord = ' w(ﾟДﾟ)w ';
      maybeFetch();
    }
  }
}
