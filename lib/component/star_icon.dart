import 'package:flutter/material.dart';

class StarIcon extends StatefulWidget {
  final bool isStar;

  const StarIcon(
    this.isStar, {
    Key key,
  }) : super(key: key);

  @override
  _StarIconState createState() => _StarIconState();
}

class _StarIconState extends State<StarIcon> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      widget.isStar ? Icons.favorite : Icons.favorite_border,
      color: widget.isStar ? Colors.redAccent : Colors.grey,
    );
  }
}
