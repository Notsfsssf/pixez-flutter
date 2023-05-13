import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/main.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class SettingCrossAdpaterPage extends StatefulWidget {
  final bool h;
  const SettingCrossAdpaterPage({Key? key, required this.h}) : super(key: key);

  @override
  State<SettingCrossAdpaterPage> createState() =>
      _SettingCrossAdpaterPageState();
}

class _SettingCrossAdpaterPageState extends State<SettingCrossAdpaterPage> {
  var _sliderValue = 100.0;
  @override
  void initState() {
    super.initState();
    _initMethod();
  }

  _initMethod() {
    final currentValue = _buildSliderValue();
    setState(() {
      _sliderValue = currentValue;
    });
  }

  @override
  void dispose() {
    _disposeMethod();
    super.dispose();
  }

  _disposeMethod() {
    final value = _sliderValue;
    if (widget.h) {
      userSetting.persisitHCrossAdapterWidth(value.toInt());
      userSetting.setHCrossAdapterWidth(value.toInt());
    } else {
      userSetting.persisitCrossAdapterWidth(value.toInt());
      userSetting.setCrossAdapterWidth(value.toInt());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Cross Adapter'),
      ),
      content: Builder(builder: (_) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Container(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Slider(
                  value: _sliderValue,
                  min: 50,
                  max: 2160,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                  onChangeEnd: (value) async {},
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      "current:${_sliderValue} screen width:$screenWidth count:${screenWidth ~/ _sliderValue}"),
                ),
              ),
              SliverWaterfallFlow(
                gridDelegate: _buildGridDelegate(_sliderValue),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                        color: Colors.grey,
                        margin: EdgeInsets.all(16),
                        child: Center(
                          child: Text(index.toString()),
                        )),
                  );
                }, childCount: 100),
              )
            ],
          ),
        );
      }),
    );
  }

  double _buildSliderValue() {
    final currentValue = (!widget.h
            ? userSetting.crossAdapterWidth
            : userSetting.hCrossAdapterWidth)
        .toDouble();
    var nowAdaptWidth = max(currentValue, 50.0);
    nowAdaptWidth = min(nowAdaptWidth, 4096);
    return nowAdaptWidth;
  }

  _buildGridDelegate(double value) {
    final count = max((MediaQuery.of(context).size.width / value), 1.0).toInt();
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }
}
