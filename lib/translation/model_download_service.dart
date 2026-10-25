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

/// 模型下载管理（规格 §9）：断点续传、镜像回退、校验、删除、本地导入。
///
/// 校验逻辑在 packages/translator 的 [ModelInstaller]（GGUF magic +
/// `max(4MiB, 标称×80%)`）；本服务只做 app 侧路径 / 设置 / 取消编排。
library;

import 'package:dio/dio.dart';
import 'package:translator/translator.dart';

import 'direct_download_channel.dart';
import 'translation_service.dart';

enum ModelDownloadPhase {
  idle,
  downloading,
  verifying,
  done,
  failed,
  cancelled,
}

class ModelDownloadState {
  final ModelDownloadPhase phase;
  final int downloaded;
  final int total;
  final int speedBps;
  final String? message;

  const ModelDownloadState({
    this.phase = ModelDownloadPhase.idle,
    this.downloaded = 0,
    this.total = hyMt2SizeBytes,
    this.speedBps = 0,
    this.message,
  });

  static const int hyMt2SizeBytes = 1133080448;

  double get progress => total <= 0 ? 0 : (downloaded / total).clamp(0.0, 1.0);

  String get sizeMb =>
      '${(downloaded / 1024 / 1024).toStringAsFixed(1)}'
      ' / ${(total / 1024 / 1024).toStringAsFixed(1)} MB';
}

class ModelDownloadService {
  final ModelInstaller _installer = ModelInstaller();
  CancelToken? _cancelToken;

  /// 直连通道（rhttp）：仅当用户开启直连且 URL 属 HuggingFace 时非空。
  RhttpDownloadChannel? _directChannel;

  /// 下载 Hy-MT2 模型；镜像回退由调用方（设置页 UI）在失败后提示切换，
  /// 不自动静默切换（规格 §9.2）。
  ///
  /// [directConnect] 开启时尝试用 rhttp 直连通道接管下载（对 HuggingFace
  /// 域名族启用无 SNI + DoH）；通道不可用（非 HF 源 / 创建异常）自动回落
  /// 默认 dio 通道。
  Stream<ModelDownloadState> download(
    String url,
    String savePath, {
    bool directConnect = false,
  }) async* {
    if (directConnect) {
      try {
        _directChannel = await RhttpDownloadChannel.create(url);
      } catch (_) {
        _directChannel = null;
      }
    } else {
      _directChannel = null;
    }
    _cancelToken = _directChannel == null ? CancelToken() : null;
    yield const ModelDownloadState(phase: ModelDownloadPhase.downloading);
    try {
      await for (final progress in _installer.download(
        url: url,
        savePath: savePath,
        declaredSize: ModelSpec.hyMt2.sizeBytes,
        cancelToken: _cancelToken,
        channel: _directChannel,
      )) {
        yield ModelDownloadState(
          phase: ModelDownloadPhase.downloading,
          downloaded: progress.downloaded,
          total: progress.total,
          speedBps: progress.speedBps,
        );
      }
      yield const ModelDownloadState(
        phase: ModelDownloadPhase.done,
        downloaded: ModelDownloadState.hyMt2SizeBytes,
      );
    } on ModelInstallCancelledException {
      // 用户主动取消：不算错误，UI 不弹 toast（进度已保留）。
      yield const ModelDownloadState(phase: ModelDownloadPhase.cancelled);
    } on ModelInstallException catch (e) {
      // HTTP 状态错误 / 校验失败 / 直连连接失败等，属于失败：
      // 提示消息（含切换镜像源等出路），由用户决定下一步。
      yield ModelDownloadState(
        phase: ModelDownloadPhase.failed,
        message: e.message,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        yield const ModelDownloadState(phase: ModelDownloadPhase.cancelled);
      } else {
        yield ModelDownloadState(
          phase: ModelDownloadPhase.failed,
          message: '$e',
        );
      }
    } catch (e) {
      yield ModelDownloadState(phase: ModelDownloadPhase.failed, message: '$e');
    } finally {
      _directChannel?.dispose();
      _directChannel = null;
      _cancelToken = null;
    }
  }

  /// 取消下载（保留 `.tmp` 以便续传）；两条通道都要打断。
  void cancel() {
    _cancelToken?.cancel();
    _directChannel?.cancel();
  }

  Future<bool> isInstalled() async {
    final path = await TranslationService.instance.modelSavePath;
    return await _installer.checkInstalled(path, ModelSpec.hyMt2.sizeBytes) !=
        null;
  }

  Future<void> delete() async {
    final path = await TranslationService.instance.modelSavePath;
    await _installer.delete(path);
  }

  Future<bool> importLocal(String sourcePath) async {
    final path = await TranslationService.instance.modelSavePath;
    try {
      await _installer.importLocal(sourcePath, path, ModelSpec.hyMt2.sizeBytes);
      return true;
    } on ModelInstallException {
      return false;
    }
  }
}
