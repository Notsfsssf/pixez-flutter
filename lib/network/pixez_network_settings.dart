import 'dart:io';

import 'package:pixez/er/hoster.dart';
import 'package:pixez/network/network_mode.dart';
import 'package:rhttp/rhttp.dart' as r;

class PixezNetworkSettings {
  static const appApiHost = 'app-api.pixiv.net';
  static const oauthHost = 'oauth.secure.pixiv.net';
  static const accountHost = 'accounts.pixiv.net';
  static const imageHost = 'i.pximg.net';
  static const imageStaticHost = 's.pximg.net';

  static r.ClientSettings? forHost(String host, NetworkMode mode) {
    if (mode == NetworkMode.standard) return null;
    if (mode == NetworkMode.ech) {
      return r.ClientSettings(
        enableEch: true,
        requireEch: true,
        tlsSettings: r.TlsSettings(
          verifyCertificates: true,
          rootCertSource: r.RootCertSource.webpki,
          sni: true,
        ),
        dnsSettings: r.DnsSettings.static(
          overrides: {
            appApiHost: ['104.18.10.118', '104.18.11.118'],
            oauthHost: ['104.18.10.118', '104.18.11.118'],
            accountHost: ['104.18.10.118', '104.18.11.118'],
          },
        ),
      );
    }
    return compatible();
  }

  static r.ClientSettings? forImages(String? host, NetworkMode mode) {
    if (mode == NetworkMode.standard) return null;
    if (host != imageHost) return null;
    return compatible();
  }

  static r.ClientSettings compatible() {
    return r.ClientSettings(
      tlsSettings: r.TlsSettings(verifyCertificates: false, sni: false),
      dnsSettings: r.DnsSettings.dynamic(
        resolver: (host) async {
          final ip = _compatibleIp(host);
          if (ip != null) return [ip];
          return await InternetAddress.lookup(
            host,
          ).then((value) => value.map((e) => e.address).toList());
        },
      ),
    );
  }

  static String? _compatibleIp(String host) {
    if (host == appApiHost) return Hoster.api();
    if (host == oauthHost) return Hoster.oauth();
    if (host == imageHost) return Hoster.iPximgNet();
    if (host == imageStaticHost) return Hoster.sPximgNet();
    return null;
  }
}
