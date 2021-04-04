import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';

class NetworkSettingPage extends StatefulWidget {
  @override
  _NetworkSettingPageState createState() => _NetworkSettingPageState();
}

class _NetworkSettingPageState extends State<NetworkSettingPage> {
  int apiStatus = 0;
  int imgStatus = 0;
  String message = "";
  late String host;
  late TextEditingController editingController;

  @override
  void initState() {
    super.initState();
    host = "210.140.92.140";
    editingController = new TextEditingController();
    editingController.addListener(() {
      host = editingController.text.toString();
    });
    initNetCheck();
  }

  initNetCheck() async {
    _apiCheck();
    _imgCheck();
  }

  _apiCheck() async {
    try {
      Response response = await apiClient.walkthroughIllusts();
      setState(() {
        apiStatus = 1;
      });
    } catch (e) {
      setState(() {
        apiStatus = 2;
      });
    }
  }

  _imgCheck() async {
    try {
      String url =
          "https://i.pximg.net/c/360x360_70/img-master/img/2016/04/29/03/33/27/56585648_p0_square1200.jpg";
      var dio = Dio(BaseOptions(headers: Hoster.header(url: url)));
      String trueUrl = url.replaceFirst(ImageHost, host);
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        HttpClient httpClient = new HttpClient();
        httpClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
        return httpClient;
      };
      Response response = await dio
          .download(trueUrl, (await getTemporaryDirectory()).path + "/s.png",
              onReceiveProgress: (min, max) {
        throw ok();
      }, deleteOnError: true);
    } catch (e) {
      if (e is ok) {
        setState(() {
          apiStatus = 1;
        });
      } else
        setState(() {
          message = e.toString();
          apiStatus = 2;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text("app-api.pixiv.net"),
            subtitle: Text("Host:" + ApiClient.BASE_API_URL_HOST),
            trailing: _buildCheckIcon(apiStatus),
          ),
          ListTile(
            title: Text(ImageHost),
            subtitle: Text("Host:" + splashStore.host),
            trailing: _buildCheckIcon(imgStatus),
          ),
          TextField(
            controller: editingController,
          ),
          TextButton(
              onPressed: () {
                host = editingController.text;
                _imgCheck();
              },
              child: Text("apply")),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildCheckIcon(int status) {
    if (status == 0) {
      return CircularProgressIndicator();
    } else if (status == 1) {
      return Icon(Icons.check);
    } else {
      return Icon(Icons.error);
    }
  }

  _showApiDialog() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(child: Container());
        });
  }
}

class ok {}
