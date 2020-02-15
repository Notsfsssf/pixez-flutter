import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/network/api_client.dart';

class NovelBookmarkButton extends StatefulWidget {
  final Novel novel;

  const NovelBookmarkButton({Key key, @required this.novel}) : super(key: key);

  @override
  _NovelBookmarkButtonState createState() => _NovelBookmarkButtonState();
}

class _NovelBookmarkButtonState extends State<NovelBookmarkButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        ApiClient client = RepositoryProvider.of<ApiClient>(context);
        if (!widget.novel.isBookmarked) {
          try {
            await client.postNovelBookmarkAdd(widget.novel.id, "private");
            setState(() {
              widget.novel.isBookmarked = true;
            });
          } catch (e) {}
        } else {
          try {
            await client.postNovelBookmarkDelete(widget.novel.id);
            setState(() {
              widget.novel.isBookmarked = false;
            });
          } catch (e) {}
        }
      },
      child: IconButton(
        icon: widget.novel.isBookmarked
            ? Icon(Icons.bookmark)
            : Icon(Icons.bookmark_border),
        onPressed: () async {
          ApiClient client = RepositoryProvider.of<ApiClient>(context);
          if (!widget.novel.isBookmarked) {
            try {
              await client.postNovelBookmarkAdd(widget.novel.id, "public");
              setState(() {
                widget.novel.isBookmarked = true;
              });
            } catch (e) {}
          } else {
            try {
              await client.postNovelBookmarkDelete(widget.novel.id);
              setState(() {
                widget.novel.isBookmarked = false;
              });
            } catch (e) {}
          }
        },
      ),
    );
  }
}
