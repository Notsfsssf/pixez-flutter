import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/main.dart';

class SettingCrossAdpaterPage extends StatefulWidget {
  final bool h;
  const SettingCrossAdpaterPage({Key? key, required this.h}) : super(key: key);

  @override
  State<SettingCrossAdpaterPage> createState() =>
      _SettingCrossAdpaterPageState();
}

class _SettingCrossAdpaterPageState extends State<SettingCrossAdpaterPage> {
  final _list = List.generate(100, (index) => index);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cross Adapter'),
      ),
      body: Observer(builder: (_) {
        final screenWidth = MediaQuery.of(context).size.width;
        final nowAdaptWidth = max(
            (!widget.h
                    ? userSetting.crossAdapterWidth
                    : userSetting.hCrossAdapterWidth)
                .toDouble(),
            100);
        return Container(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Slider(
                  value: nowAdaptWidth.toDouble(),
                  min: 100,
                  max: MediaQuery.of(context).size.width,
                  onChanged: (value) {
                    if (widget.h)
                      userSetting.setHCrossAdapterWidth(value.toInt());
                    else
                      userSetting.setCrossAdapterWidth(value.toInt());
                  },
                  onChangeEnd: (value) async {
                    if (widget.h)
                      userSetting.persisitHCrossAdapterWidth(value.toInt());
                    else
                      userSetting.persisitCrossAdapterWidth(value.toInt());
                  },
                ),
              ),
              SliverGrid.count(
                crossAxisCount: screenWidth ~/ nowAdaptWidth,
                children: [
                  for (final i in _list)
                    Container(
                      color: Colors.grey,
                      margin: EdgeInsets.all(16),
                      child: Center(
                        child: Text(i.toString()),
                      ),
                    )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
