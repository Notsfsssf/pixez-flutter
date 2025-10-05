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

import 'package:flutter/material.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/novel/novel_rail.dart';

class MultiFunctionFab extends StatefulWidget {
  final VoidCallback onRefresh;

  const MultiFunctionFab({Key? key, required this.onRefresh}) : super(key: key);

  @override
  _MultiFunctionFabState createState() => _MultiFunctionFabState();
}

class _MultiFunctionFabState extends State<MultiFunctionFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 跳转到小说首页按钮
        if (_isExpanded)
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                heroTag: "fab_novel",
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NovelRail()));
                  _toggleExpanded();
                },
                child: Icon(Icons.book),
                mini: true,
              ),
            ),
          ),
        // 回到顶部按钮
        if (_isExpanded)
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                heroTag: "fab_top",
                onPressed: () {
                  // 发送回到顶部信号
                  topStore.setTop("100");
                  _toggleExpanded();
                },
                child: Icon(Icons.arrow_upward),
                mini: true,
              ),
            ),
          ),
        // 刷新按钮
        if (_isExpanded)
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                heroTag: "fab_refresh",
                onPressed: () {
                  widget.onRefresh();
                  _toggleExpanded();
                },
                child: Icon(Icons.refresh),
                mini: true,
              ),
            ),
          ),
        // 主按钮
        FloatingActionButton(
          heroTag: "fab_main",
          onPressed: _toggleExpanded,
          child: Icon(_isExpanded ? Icons.close : Icons.menu),
        ),
      ],
    );
  }
}