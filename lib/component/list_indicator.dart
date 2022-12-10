import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ListIndicator extends StatefulWidget {
  void Function()? onTop;
  ListIndicator({super.key, this.onTop});

  @override
  State<ListIndicator> createState() => _ListIndicatorState();
}

class _ListIndicatorState extends State<ListIndicator> {
  var _showOffset = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_drop_up_outlined,
                size: 24,
              ),
              onPressed: () {
                widget.onTop?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
