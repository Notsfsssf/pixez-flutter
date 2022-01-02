import 'package:flutter/material.dart';

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
    parseComment();
  }

  parseComment() {
    _text.indexOf("pattern");
  }

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: []));
  }
}
