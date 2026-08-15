import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:html/parser.dart' show parse;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/saucenao/sauce_nao_result.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum _SauceNaoPhase { idle, loading, done, error }

class SauceNaoModal extends StatefulWidget {
  const SauceNaoModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const SauceNaoModal(),
    );
  }

  @override
  State<SauceNaoModal> createState() => _SauceNaoModalState();
}

class _SauceNaoModalState extends State<SauceNaoModal> {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://saucenao.com"));
  CancelToken? _cancelToken;
  _SauceNaoPhase _phase = _SauceNaoPhase.idle;
  String? _errorMessage;
  String? _pickedPath;
  final List<SauceNaoResult> _results = [];

  @override
  void dispose() {
    _cancelToken?.cancel("disposed");
    _dio.close(force: true);
    super.dispose();
  }

  void _cancelRequest() {
    _cancelToken?.cancel("cancelled");
    _cancelToken = null;
    if (mounted && _phase == _SauceNaoPhase.loading) {
      setState(() {
        _phase = _SauceNaoPhase.idle;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickAndSearch() async {
    await _ensurePhotoPickerPreference();
    final picker = ImagePicker();
    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker =
          userSetting.imagePickerType == 1;
    }
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null || !mounted) return;

    final originImageBytes = await pickedFile.readAsBytes();
    final newImageBytes = _compressImage(originImageBytes);
    LPrinter.d(
      "Uncompressed image size: ${originImageBytes.length}, compressed image size: ${newImageBytes.length}",
    );
    final path =
        "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
    await File(path).writeAsBytes(newImageBytes);
    if (!mounted) return;

    setState(() {
      _pickedPath = path;
      _phase = _SauceNaoPhase.loading;
      _errorMessage = null;
      _results.clear();
    });
    await _search(path);
  }

  Future<void> _retry() async {
    final path = _pickedPath;
    if (path == null) {
      await _pickAndSearch();
      return;
    }
    if (!mounted) return;
    setState(() {
      _phase = _SauceNaoPhase.loading;
      _errorMessage = null;
      _results.clear();
    });
    await _search(path);
  }

  Future<void> _search(String path) async {
    _cancelToken?.cancel("restart");
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    try {
      final formData = FormData();
      formData.files.add(MapEntry("file", await MultipartFile.fromFile(path)));

      final response = await _dio.post(
        '/search.php',
        data: formData,
        cancelToken: cancelToken,
      );
      if (!mounted || cancelToken.isCancelled) return;

      final results = _parseResponse(response.data);
      setState(() {
        _results
          ..clear()
          ..addAll(results);
        _phase = _SauceNaoPhase.done;
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || !mounted) return;
      setState(() {
        _phase = _SauceNaoPhase.error;
        _errorMessage = e.message ?? e.toString();
      });
    } catch (e) {
      if (!mounted || cancelToken.isCancelled) return;
      setState(() {
        _phase = _SauceNaoPhase.error;
        _errorMessage = e.toString();
      });
    } finally {
      if (identical(_cancelToken, cancelToken)) {
        _cancelToken = null;
      }
    }
  }

  List<SauceNaoResult> _parseResponse(dynamic raw) {
    try {
      final decoded = raw is String
          ? jsonDecode(raw)
          : raw is Map
          ? raw
          : null;
      if (decoded is Map) {
        return _parseJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    if (raw is String) {
      return _parseHtml(raw);
    }
    return [];
  }

  List<SauceNaoResult> _parseJson(Map<String, dynamic> json) {
    final results = <SauceNaoResult>[];
    final seen = <int>{};
    final items = json['results'];
    if (items is! List) return results;

    for (final item in items) {
      if (item is! Map) continue;
      final header = item['header'];
      final data = item['data'];
      if (data is! Map) continue;

      final illustId = _extractPixivId(Map<String, dynamic>.from(data));
      if (illustId == null || !seen.add(illustId)) continue;

      results.add(
        SauceNaoResult(
          illustId: illustId,
          thumbnail: header is Map ? header['thumbnail']?.toString() : null,
          similarity: header is Map ? header['similarity']?.toString() : null,
          title: data['title']?.toString(),
          author: (data['member_name'] ?? data['author_name'] ?? data['author'])
              ?.toString(),
        ),
      );
    }
    return results;
  }

  List<SauceNaoResult> _parseHtml(String html) {
    final results = <SauceNaoResult>[];
    final seen = <int>{};
    final document = parse(html);

    final resultNodes = document.querySelectorAll('.result');
    if (resultNodes.isNotEmpty) {
      for (final node in resultNodes) {
        int? illustId;
        String? title;
        String? author;
        for (final anchor in node.querySelectorAll('a')) {
          final link = anchor.attributes['href'];
          if (link == null) continue;
          final id = _extractPixivIdFromUrl(link);
          if (id != null) {
            illustId = id;
            break;
          }
        }
        if (illustId == null || !seen.add(illustId)) continue;

        final thumbnail =
            node.querySelector('.resultimage img')?.attributes['src'] ??
            node.querySelector('img')?.attributes['src'];
        final similarity = node
            .querySelector('.resultsimilarityinfo')
            ?.text
            .trim();
        title = node.querySelector('.resulttitle')?.text.trim();
        final memberAnchors = node.querySelectorAll('a').where((a) {
          final href = a.attributes['href'] ?? '';
          return href.contains('member.php') || href.contains('/users/');
        });
        if (memberAnchors.isNotEmpty) {
          author = memberAnchors.first.text.trim();
        }

        results.add(
          SauceNaoResult(
            illustId: illustId,
            thumbnail: thumbnail,
            similarity: similarity,
            title: title,
            author: author,
          ),
        );
      }
      if (results.isNotEmpty) return results;
    }

    for (final element in document.querySelectorAll('a')) {
      final link = element.attributes['href'];
      if (link == null) continue;
      final illustId = _extractPixivIdFromUrl(link);
      if (illustId == null || !seen.add(illustId)) continue;

      final imgEl =
          element.querySelector('img') ?? element.parent?.querySelector('img');
      results.add(
        SauceNaoResult(illustId: illustId, thumbnail: imgEl?.attributes['src']),
      );
    }
    return results;
  }

  int? _extractPixivId(Map<String, dynamic> data) {
    final pixivId = data['pixiv_id'];
    if (pixivId is int) return pixivId;
    if (pixivId is String) return int.tryParse(pixivId);

    final extUrls = data['ext_urls'];
    if (extUrls is List) {
      for (final url in extUrls) {
        final id = _extractPixivIdFromUrl(url?.toString() ?? '');
        if (id != null) return id;
      }
    }
    return null;
  }

  int? _extractPixivIdFromUrl(String link) {
    if (!link.contains('pixiv.net')) return null;
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    final fromQuery = uri.queryParameters['illust_id'];
    if (fromQuery != null) return int.tryParse(fromQuery);
    final match = RegExp(r'artworks/(\d+)').firstMatch(link);
    if (match != null) return int.tryParse(match.group(1)!);
    return null;
  }

  Uint8List _compressImage(Uint8List originImageBytes) {
    final originImage = img.decodeImage(originImageBytes);
    final originWidth = originImage!.width;
    final originHeight = originImage.height;
    int newWidth, newHeight;
    if (originWidth < 720 || originHeight < 720) {
      newWidth = originWidth;
      newHeight = originHeight;
    } else if (originWidth > originHeight) {
      newHeight = 720;
      newWidth = originWidth * newHeight ~/ originHeight;
    } else {
      newWidth = 720;
      newHeight = originHeight * newWidth ~/ originWidth;
    }
    final newImage = img.copyResize(
      originImage,
      width: newWidth,
      height: newHeight,
    );
    return img.encodeJpg(newImage, quality: 75);
  }

  Future<void> _ensurePhotoPickerPreference() async {
    if (!Platform.isAndroid || !mounted) return;
    final skipAlert = Prefer.getBool("photo_picker_type_selected") ?? false;
    if (skipAlert) return;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Observer(
                builder: (context) {
                  return SwitchListTile(
                    secondary: Icon(Icons.photo_album),
                    onChanged: (bool value) async {
                      await userSetting.setImagePickerType(value ? 1 : 0);
                    },
                    title: InkWell(
                      child: Text(I18n.of(context).photo_picker),
                      onTap: () {
                        launchUrlString(
                          "https://developer.android.com/training/data-storage/shared/photopicker",
                        );
                      },
                    ),
                    subtitle: Text(I18n.of(context).photo_picker_subtitle),
                    value: userSetting.imagePickerType == 1,
                  );
                },
              ),
              Divider(),
              InkWell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(I18n.of(context).ok),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
    await Prefer.setBool("photo_picker_type_selected", true);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _cancelRequest();
      },
      child: SafeArea(
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                title: Text("SauceNao"),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _cancelRequest();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Divider(height: 1),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_phase) {
      case _SauceNaoPhase.idle:
        return _buildIdle(context);
      case _SauceNaoPhase.loading:
        return _buildLoading(context);
      case _SauceNaoPhase.done:
        return _buildResults(context);
      case _SauceNaoPhase.error:
        return _buildError(context);
    }
  }

  Widget _buildIdle(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_search,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _pickAndSearch,
              icon: Icon(Icons.add_photo_alternate),
              label: Text(I18n.of(context).upload_picture),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pickedPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_pickedPath!),
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(I18n.of(context).uploading),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _cancelRequest();
                Navigator.of(context).pop();
              },
              child: Text(I18n.of(context).cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.2,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _errorMessage ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _retry,
              child: Text(I18n.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(I18n.of(context).no_result),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _pickAndSearch,
                icon: Icon(Icons.add_photo_alternate),
                label: Text(I18n.of(context).upload_picture),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  I18n.of(
                    context,
                  ).tap_to_show_results(_results.length.toString()),
                ),
              ),
              TextButton.icon(
                onPressed: _pickAndSearch,
                icon: Icon(Icons.add_photo_alternate),
                label: Text(I18n.of(context).upload_picture),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _results[index];
              return ListTile(
                leading: _PixivIllustThumbnail(illustId: item.illustId),
                title: Text(
                  item.title?.isNotEmpty == true
                      ? item.title!
                      : "Pixiv #${item.illustId}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  [
                    if (item.similarity != null)
                      item.similarity!.contains('%')
                          ? item.similarity
                          : "${item.similarity}%",
                    if (item.author?.isNotEmpty == true) item.author,
                    "#${item.illustId}",
                  ].whereType<String>().join(" · "),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Leader.push(context, IllustLightingPage(id: item.illustId));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PixivIllustThumbnail extends StatefulWidget {
  final int illustId;

  const _PixivIllustThumbnail({required this.illustId});

  @override
  State<_PixivIllustThumbnail> createState() => _PixivIllustThumbnailState();
}

class _PixivIllustThumbnailState extends State<_PixivIllustThumbnail> {
  String? _imageUrl;
  bool _loading = true;
  static bool _authBroken = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant _PixivIllustThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.illustId != widget.illustId) {
      _imageUrl = null;
      _loading = true;
      _fetch();
    }
  }

  Future<void> _fetch() async {
    if (_authBroken) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      // apiClient 拦截器会自动带 Authorization: Bearer <access_token>
      final response = await apiClient.getIllustDetail(widget.illustId);
      final illust = Illusts.fromJson(response.data['illust']);
      if (!mounted) return;
      setState(() {
        _imageUrl = illust.imageUrls.squareMedium;
        _loading = false;
      });
    } catch (e) {
      final message = e.toString();
      if (message.contains('OAuth') || message.contains('invalid_request')) {
        _authBroken = true;
      }
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Widget _placeholder({bool failed = false}) {
    return Container(
      width: 56,
      height: 56,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: failed
          ? Text(':(', style: Theme.of(context).textTheme.headlineMedium)
          : const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = _imageUrl == null
        ? _placeholder(failed: !_loading)
        : CachedNetworkImage(
            imageUrl: _imageUrl!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            cacheManager: pixivCacheManager,
            httpHeaders: Hoster.header(url: _imageUrl),
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _placeholder(failed: true),
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(width: 56, height: 56, child: child),
    );
  }
}
