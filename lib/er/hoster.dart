import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/main.dart';

class Hoster {
  static String host(String url) {
    try {} catch (e) {}
    return splashStore.host;
  }

  static Map<String, String> header({String? url}) {
    Map<String, String> map = {
      "referer": "https://app-api.pixiv.net/",
      "User-Agent": "PixivIOSApp/5.8.0",
      "Host": "i.pximg.net"
    };
    if (url != null) {
      String host = Uri.parse(url).host;
      if (host == ImageHost) {
        if (userSetting.disableBypassSni) return map;
        map['Host'] = userSetting.pictureSource!;
      } else {
        if (userSetting.pictureSource == ImageHost) {
          map['Host'] = host;
        } else{
          map['Host'] = userSetting.pictureSource!;
        }
      }
    }
    return map;
  }
}
