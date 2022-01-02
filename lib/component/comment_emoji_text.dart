import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:pixez/page/comment/comment_store.dart';

class CommentEmojiText extends StatefulWidget {
  final String text;
  const CommentEmojiText({Key? key, required this.text}) : super(key: key);

  @override
  _CommentEmojiTextState createState() => _CommentEmojiTextState();
}

class _CommentEmojiTextState extends State<CommentEmojiText> {
  late String _text;

  @override
  void initState() {
    _text = widget.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedText(
      _text,
      specialTextSpanBuilder: EmojisSpecialTextSpanBuilder(),
    );
  }
}

class PixivEmojiSpan extends ExtendedWidgetSpan {
  final String name;
  PixivEmojiSpan(this.name)
      : super(
            child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset('assets/emojis/${emojisMap[name]}',width: 32,height: 32,),
        ));
}

class SpecialEmojiImageText extends SpecialText {
  static const String flag = '(';

  SpecialEmojiImageText(TextStyle? textStyle)
      : super(SpecialEmojiImageText.flag, ')', textStyle);

  @override
  InlineSpan finishText() {
    final String key = toString();
    if (key.isNotEmpty && emojisMap[key] != null) {
      return PixivEmojiSpan(key);
    } else {
      return TextSpan(text: key);
    }
  }
}

class EmojisSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      required int index}) {
    if (flag == null || flag == '') {
      return null;
    }
    if (isStart(flag, "(")) {
      return SpecialEmojiImageText(textStyle);
    }
    return null;
  }
}
