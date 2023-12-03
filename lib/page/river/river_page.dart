import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/river/river_provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class RiverPage extends HookConsumerWidget {
  final illustsProvider =
      StateNotifierProvider<IllustListNotifier, IllustListState>((ref) {
    return IllustListNotifier(ref);
  });

  @override
  Widget build(Object context, WidgetRef ref) {
    final provider = ref.watch(illustsProvider);
    final illusts = provider.illusts;
    final offset = provider.offset;
    final scrollController = useScrollController();
    useEffect(() {
      ref.read(illustsProvider.notifier).fetch(offset: 0);
      return null;
    }, []);
    // ref.read(illustsProvider.notifier).fetch();

    return Scaffold(
      appBar: AppBar(
        title: Text("${offset ?? 0}"),
        actions: [
          IconButton(
              onPressed: () {
                ref.read(illustsProvider.notifier).fetch(offset: offset ?? 0);
              },
              icon: Icon(Icons.next_plan))
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverWaterfallFlow(
                gridDelegate: _buildGridDelegate(ref.context),
                delegate:
                    _buildSliverChildBuilderDelegate(ref.context, illusts),
              )
            ],
          ),
        ],
      ),
    );
  }

  SliverChildBuilderDelegate _buildSliverChildBuilderDelegate(
      BuildContext context, List<Illusts> illusts) {
    return SliverChildBuilderDelegate((BuildContext context, int index) {
      final illust = illusts[index];
      return Card(
        child: PixivImage(illust.imageUrls.medium),
      );
    }, childCount: illusts.length);
  }

  SliverWaterfallFlowDelegate _buildGridDelegate(context) {
    var count = 2;
    if (userSetting.crossAdapt) {
      count = _buildSliderValue(context);
    } else {
      count = (MediaQuery.of(context).orientation == Orientation.portrait)
          ? userSetting.crossCount
          : userSetting.hCrossCount;
    }
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }

  int _buildSliderValue(context) {
    final currentValue =
        (MediaQuery.of(context).orientation == Orientation.portrait
                ? userSetting.crossAdapterWidth
                : userSetting.hCrossAdapterWidth)
            .toDouble();
    var nowAdaptWidth = max(currentValue, 50.0);
    nowAdaptWidth = min(nowAdaptWidth, 2160.0);
    final screenWidth = MediaQuery.of(context).size.width;
    final result = max(screenWidth / nowAdaptWidth, 1.0).toInt();
    return result;
  }
}
