import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
     child: ListView.builder(itemBuilder: (BuildContext context, int index) {
       return Container(child: LinearProgressIndicator(value: 0,),);
     },), 
    );
  }
}