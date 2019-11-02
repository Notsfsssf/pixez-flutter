import 'package:flutter/material.dart';
import 'package:pixez/page/comment/comment_store.dart';

class CommentEmojiText extends StatefulWidget {
  final String text;
  const CommentEmojiText({Key? key, required this.text}) : super(key: key);

  @override
  _CommentEmojiTextState createState() => _CommentEmojiTextState();
}

class _CommentEmojiTextState extends State<CommentEmojiText> {
  List<InlineSpan> _spans = [];

  @override
  void initState() {
    super.initState();
    _buildSpans();
  }

  @override
  void didUpdateWidget(CommentEmojiText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _buildSpans();
    }
  }

  _buildSpans() {
    String text = widget.text;
    List<InlineSpan> spans = [];
    String template = "";
    String emojiText = "";
    bool emojiCollecting = false;
    for (var element in text.characters) {
      if (element == '(') {
        if (template.isNotEmpty) {
          spans.add(TextSpan(text: template));
          template = "";
        }
        emojiCollecting = true;
      } else if (element == ')') {
        if (emojiText.isNotEmpty) {
          final key = "($emojiText)";
          if (emojisMap.containsKey(key)) {
            spans.add(WidgetSpan(
                child: Image.asset(
              'assets/emojis/${emojisMap[key]}',
              width: 20,
              height: 20,
            )));
          } else {
            spans.add(TextSpan(text: "($emojiText)"));
            template = "";
          }
        }
        emojiCollecting = false;
        emojiText = "";
      } else {
        if (emojiCollecting)
          emojiText += element;
        else
          template += element;
      }
    }
    if (template.isNotEmpty) {
      spans.add(TextSpan(text: template));
    }
    setState(() {
      _spans = spans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [for (var i in _spans) i],
      ),
    );
  }
}
