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

/// 云端（OpenAI 兼容）接口地址规范化。
///
/// 用户填进来的地址五花八门，直接交给 Dio 会踩三类坑：
/// 1. 只填 `192.168.1.5:8080/v1`（没有 scheme）——Dio 拼不出绝对 URL，
///    报「No host specified in URI」；
/// 2. 末尾带 `/` ——BaseOptions.baseUrl + `/chat/completions` 变成
///    `//chat/completions`，不少自建服务直接 404；
/// 3. 把完整端点 `…/v1/chat/completions` 一起粘进来 ——同样拼成双份路径。
///
/// 这里统一收口：缺 scheme 时局域网/本机默认 http、公网域名默认 https，
/// 去掉尾部斜杠与误粘的 `/chat/completions`。
library;

/// 规范化接口地址；无法解析或 scheme 不是 http/https 时返回 null。
///
/// 返回值不带尾斜杠，可直接作为 `Dio.options.baseUrl`。
String? normalizeCloudBaseUrl(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return null;

  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*://').hasMatch(value)) {
    // 没写协议：局域网/本机按 http，公网域名按 https（避免把 key 明文发出去）。
    final host = _hostOf(value);
    value = '${_looksLocal(host) ? 'http' : 'https'}://$value';
  }

  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return null;
  if (uri.host.isEmpty) return null;

  var path = uri.path;
  const endpointSuffix = '/chat/completions';
  if (path.endsWith(endpointSuffix)) {
    path = path.substring(0, path.length - endpointSuffix.length);
  }
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  return Uri(
    scheme: scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: path,
  ).toString();
}

/// 是否为局域网 / 本机 host。
///
/// 云端接口地址若指向这类 host，Android 17 需要额外的本地网络权限。
bool isLocalNetworkHost(String host) => _looksLocal(host);

/// 从「host[:port][/path]」里取出 host（用于判断该不该默认 http）。
String _hostOf(String value) {
  var host = value;
  final slash = host.indexOf('/');
  if (slash >= 0) host = host.substring(0, slash);
  final at = host.lastIndexOf('@');
  if (at >= 0) host = host.substring(at + 1);
  // IPv6 字面量是 [::1]:8080，先保留方括号内的内容。
  if (host.startsWith('[')) {
    final end = host.indexOf(']');
    return end > 0 ? host.substring(1, end) : host;
  }
  final colon = host.lastIndexOf(':');
  if (colon >= 0) host = host.substring(0, colon);
  return host;
}

/// 本机 / 局域网地址判定：这类地址默认走 http（自建服务通常没有证书）。
bool _looksLocal(String host) {
  final h = host.toLowerCase();
  if (h.isEmpty) return false;
  if (h == 'localhost' || h == '::1') return true;
  if (h.endsWith('.local') || h.endsWith('.lan') || h.endsWith('.home')) {
    return true;
  }
  if (_isPrivateIpv4(h)) return true;
  // IPv6 链路本地 / 唯一本地地址（fe80::/10、fc00::/7）。
  if (h.startsWith('fe80:') || h.startsWith('fc') || h.startsWith('fd')) {
    return true;
  }
  // 无点主机名多半是路由器 / NAS 的局域网别名，例如 `nas:8080`。
  if (!h.contains('.') && !h.contains(':')) return true;
  return false;
}

bool _isPrivateIpv4(String host) {
  final parts = host.split('.');
  if (parts.length != 4) return false;
  final nums = <int>[];
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0 || n > 255) return false;
    nums.add(n);
  }
  // 10/8、127/8、192.168/16、172.16/12、169.254/16（链路本地）。
  if (nums[0] == 10 || nums[0] == 127) return true;
  if (nums[0] == 192 && nums[1] == 168) return true;
  if (nums[0] == 172 && nums[1] >= 16 && nums[1] <= 31) return true;
  if (nums[0] == 169 && nums[1] == 254) return true;
  return false;
}
