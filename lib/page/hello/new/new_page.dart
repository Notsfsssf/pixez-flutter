import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/page/hello/new/new_illust/new_illust_page.dart';
import 'package:pixez/page/hello/new/painter/new_painter_page.dart';

class NewPage extends StatefulWidget {
  @override
  _NewPageState createState() => _NewPageState();
}

enum WhyFarther { public, private }

class _NewPageState extends State<NewPage> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TabController(initialIndex: _selectIndex, vsync: this, length: 3);
    _controller.addListener(() {
      setState(() {
        _selectIndex = this._controller.index;
        print(_controller.index);
      });
    });
  }

  List<Widget> _buildActions() {
    switch (_selectIndex) {
      case 1:
        {
          return <Widget>[
            PopupMenuButton<WhyFarther>(
              initialValue: WhyFarther.public,
              onSelected: (WhyFarther result) {},
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<WhyFarther>>[
                const PopupMenuItem<WhyFarther>(
                  value: WhyFarther.public,
                  child: Text('Working a lot harder'),
                ),
                const PopupMenuItem<WhyFarther>(
                  value: WhyFarther.private,
                  child: Text('Being a lot smarter'),
                ),
              ],
            )
          ];
        }
        break;
      case 2:
        {
          return <Widget>[
            PopupMenuButton<WhyFarther>(
              initialValue: WhyFarther.public,
              onSelected: (WhyFarther result) {},
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<WhyFarther>>[
                const PopupMenuItem<WhyFarther>(
                  value: WhyFarther.public,
                  child: Text('Working a lot harder'),
                ),
                const PopupMenuItem<WhyFarther>(
                  value: WhyFarther.private,
                  child: Text('Being a lot smarter'),
                ),
              ],
            )
          ];
        }
        break;
      default:
        {
          return [];
        }
        break;
    }
  }

  int _selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My"),
        bottom: TabBar(
          controller: _controller,
          tabs: [
            Tab(
              text: "Illust",
            ),
            Tab(
              text: "BookMark",
            ),
            Tab(
              text: "Painter",
            ),
          ],
        ),
        actions: _buildActions(),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          NewIllustPage(),
          Container(),
          BlocBuilder<RouteBloc, RouteState>(
            builder: (context, state) {
              if (state is HasUserState) {
                return NewPainterPage(
                  id: int.parse(state.list.userId),
                );
              } else
                return Container();
            },
          )
        ],
      ),
    );
  }
}
