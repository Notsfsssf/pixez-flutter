import 'package:flutter/material.dart';

import 'network_page.dart';

class NetworkSelectPage extends StatefulWidget {
  @override
  _NetworkSelectPageState createState() => _NetworkSelectPageState();
}

class _NetworkSelectPageState extends State<NetworkSelectPage> {
  @override
  Widget build(BuildContext context) {
    return NetworkPage(automaticallyImplyLeading: false);
  }
}
