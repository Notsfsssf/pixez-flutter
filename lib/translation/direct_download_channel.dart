/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/// 模型下载「直连通道」：复用 app 的 rhttp（Rust reqwest）网络栈，
/// 用 DoH 解析真实 IP，绕过针对 HuggingFace 的 **DNS 污染**层。
///
/// 2026-10-24 实测结论（写死在此以免后人重走弯路）：
/// - huggingface.co 及其 LFS/Xet CDN 全部在 **AWS CloudFront**（52.222.x /
///   18.245.x / 13.226.x），**不在 Cloudflare**；
/// - 国内 DoH 对 HF 的应答不可信：360 直接返回 Facebook 的污染 IP，
///   阿里返回陈旧 EC2 地址；doh.pub 实测返回真实 CloudFront 段（首选），
///   其 HTTPS(type 65) 记录也被污染（无 ECH 配置可取）；
/// - TLS 层 **SNI 黑名单阻断**（真 IP + SNI 握手即被 RST）；无 SNI 则
///   CloudFront 直接拒绝（仅 Cloudflare 支持无 SNI + Host 路由，pixiv
///   compat 模式依赖的正是这一点，对 HF 不成立）。
/// 因此本通道只解决 DNS 污染层：TLS 走正常 SNI + 完整证书校验；
/// 在 SNI 未被阻断的网络中可用，被阻断的网络会连接失败（此时应改用
/// hf-mirror.net 等镜像源，断点续传语义不受通道影响）。
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rhttp/rhttp.dart' as r;
import 'package:translator/translator.dart';

/// HuggingFace 域名族：主站与 LFS / Xet CDN 的重定向目标都在这两个后缀下。
bool _isHuggingFaceHost(String host) =>
    host == 'huggingface.co' ||
    host.endsWith('.huggingface.co') ||
    host == 'hf.co' ||
    host.endsWith('.hf.co');

/// DoH（DNS over HTTPS，JSON API）：加密查询可绕过链路 DNS 污染。
///
/// 顺序即优先级：doh.pub（腾讯）实测对 HF 返回真实 CloudFront 段；
/// dns.alidns.com（阿里）返回陈旧结果仅作后备；360 已实测返回污染
/// IP，不要加入。
const List<String> _dohEndpoints = [
  'https://doh.pub/dns-query',
  'https://dns.alidns.com/resolve',
];

/// rhttp 实现的模型下载直连通道。
class RhttpDownloadChannel implements DownloadChannel {
  final r.RhttpClient _client;
  final r.CancelToken _cancelToken = r.CancelToken();

  RhttpDownloadChannel._(this._client);

  /// 按下载 URL 创建通道。
  ///
  /// 返回 null 表示该 URL 无需直连（非 HuggingFace 源走默认 dio 通道）。
  static Future<RhttpDownloadChannel?> create(String url) async {
    final host = Uri.tryParse(url.trim())?.host ?? '';
    if (!_isHuggingFaceHost(host)) return null;
    final client = await r.RhttpClient.create(
      settings: r.ClientSettings(
        dnsSettings: r.DnsSettings.dynamic(resolver: _resolve),
        redirectSettings: const r.RedirectSettings.limited(8),
      ),
    );
    return RhttpDownloadChannel._(client);
  }

  /// DNS 解析：HF 域名族逐家 DoH 查询真实 IP（系统 DNS 对其污染），
  /// 全部失败回落系统 DNS；其余域名直接系统 DNS。
  /// 结果统一过滤内网 / 保留地址，防止解析结果把连接引向私有网段。
  static Future<List<String>> _resolve(String host) async {
    var ips = const <String>[];
    if (_isHuggingFaceHost(host)) {
      for (final endpoint in _dohEndpoints) {
        ips = await _dohResolve(endpoint, host);
        if (ips.isNotEmpty) break;
      }
    }
    if (ips.isEmpty) {
      try {
        ips = await InternetAddress.lookup(
          host,
        ).then((v) => v.map((e) => e.address).toList());
      } catch (_) {
        return const [];
      }
    }
    // 防御：丢弃解析结果中的内网 / 保留 IP。
    return ips
        .where((ip) => !ModelInstaller.isRestrictedHost(ip))
        .toList();
  }

  static final Dio _dohDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  /// DoH JSON API 查询 A 记录。
  static Future<List<String>> _dohResolve(String endpoint, String host) async {
    try {
      final resp = await _dohDio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'name': host, 'type': 'A'},
      );
      final answer = resp.data?['Answer'];
      if (answer is List) {
        return [
          for (final e in answer)
            if (e is Map && e['type'] == 1 && e['data'] is String)
              e['data'] as String,
        ];
      }
    } catch (_) {
      // 单家 DoH 不可用时换下一家 / 回落系统 DNS（见 _resolve）。
    }
    return const [];
  }

  @override
  Future<DownloadResponse> open(
    String url, {
    Map<String, String>? headers,
  }) async {
    final r.HttpStreamResponse resp;
    try {
      resp = await _client.getStream(
        url,
        headers: headers == null ? null : r.HttpHeaders.rawMap(headers),
        cancelToken: _cancelToken,
      );
    } on r.RhttpCancelException {
      throw ModelDownloadCancelled();
    } on r.RhttpConnectionException {
      // 2026-10 实测：对 HF 做 SNI 阻断的网络在此处表现为连接被重置
      //（errno 104）。给出可执行的出路，而不是原始异常文本。
      throw ModelInstallException(
        '直连连接失败：连接被网络重置（对 HuggingFace 的阻断）。'
        '请切换下载源（推荐 hf-mirror.net）或关闭直连开关',
      );
    }
    return DownloadResponse(
      statusCode: resp.statusCode,
      headers: resp.headerMapList,
      // rhttp 的取消/连接错误既可能在请求阶段、也可能在流消费阶段抛出，
      // 统一转译为可读的安装异常。
      stream: resp.body.handleError((Object error) {
        if (error is r.RhttpCancelException) throw ModelDownloadCancelled();
        if (error is r.RhttpConnectionException) {
          throw ModelInstallException(
            '连接被网络重置：已保留已下载进度，可重试续传，'
            '或切换下载源（推荐 hf-mirror.net）',
          );
        }
        throw error;
      }),
    );
  }

  /// 取消下载（安装器据此保留 `.tmp` 供续传）。
  void cancel() => _cancelToken.cancel();

  void dispose() => _client.dispose(cancelRunningRequests: true);
}
