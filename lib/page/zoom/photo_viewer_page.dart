/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:share_extend/share_extend.dart';

class PhotoViewerPage extends StatefulWidget {
  final int index;
  final Illusts illusts;

  const PhotoViewerPage({Key key, this.index, this.illusts}) : super(key: key);

  @override
  _PhotoViewerPageState createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  var index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  Widget _buildPager() => PageView(
        pageSnapping: false,
        onPageChanged: (index) {
          setState(() {
            this.index = index;
          });
        },
        controller: PageController(initialPage: widget.index),
        children: [
          for (var f in widget.illusts.metaPages)
            PhotoView(
                imageProvider: PixivProvider.url(userSetting.zoomQuality == 0
                    ? f.imageUrls.large
                    : f.imageUrls.original))
        ],
      );

  Widget _buildMuti() => InkWell(
        onLongPress: () async {
          final url = userSetting.zoomQuality == 0
              ? widget.illusts.metaPages[index].imageUrls.large
              : widget.illusts.metaPages[index].imageUrls.original;
          File fileInfo = await getCachedImageFile(url);
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              builder: (_) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(I18n.of(context).save),
                        onTap: () {
                          saveStore.saveImage(widget.illusts, index: index);
                          Navigator.of(context).pop();
                        },
                      ),
                      fileInfo != null
                          ? ListTile(
                              title: Text(I18n.of(context).share),
                              onTap: () async {
                                if (fileInfo != null)
                                  ShareExtend.share(fileInfo.path, "image");
                                Navigator.of(context).pop();
                              },
                            )
                          : Container(
                              height: 0,
                            ),
                    ],
                  ),
                );
              });
        },
        child: PhotoViewGallery.builder(
            onPageChanged: (i) {
              setState(() {
                this.index = i;
              });
            },
            pageController: PageController(initialPage: widget.index),
            itemCount: widget.illusts.metaPages.length,
            builder: (context, index) {
              final url = userSetting.zoomQuality == 0
                  ? widget.illusts.metaPages[index].imageUrls.large
                  : widget.illusts.metaPages[index].imageUrls.original;
              return PhotoViewGalleryPageOptions(
                imageProvider: PixivProvider.url(url),
                initialScale: PhotoViewComputedScale.contained * 1,
                heroAttributes: PhotoViewHeroAttributes(tag: url),
              );
            }),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            "${index + 1}/${widget.illusts.pageCount}",
            style: TextStyle(color: Colors.white),
          ),
        ),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: widget.illusts.pageCount == 1
            ? InkWell(
                onLongPress: () async {
                  final url = userSetting.zoomQuality == 0
                      ? widget.illusts.imageUrls.large
                      : widget.illusts.metaSinglePage.originalImageUrl;
                  File fileInfo = await getCachedImageFile(url);
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.0))),
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text(I18n.of(context).save),
                                onTap: () {
                                  saveStore.saveImage(widget.illusts);
                                  Navigator.of(context).pop();
                                },
                              ),
                              fileInfo != null
                                  ? ListTile(
                                      title: Text(I18n.of(context).share),
                                      onTap: () async {
                                        ShareExtend.share(
                                            fileInfo.path, "image");
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  : Container(
                                      height: 0,
                                    ),
                            ],
                          ),
                        );
                      });
                },
                child: PhotoView(
                  imageProvider: PixivProvider.url(userSetting.zoomQuality == 0
                      ? widget.illusts.imageUrls.large
                      : widget.illusts.metaSinglePage.originalImageUrl),
                ),
              )
            : _buildMuti());
  }
}
