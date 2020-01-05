import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

import './bloc.dart';

class SoupBloc extends Bloc<SoupEvent, SoupState> {
  final dio = Dio(BaseOptions(headers: {
    'user-agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
    'referer': 'https://www.pixivision.net/zh/'
  }));

  @override
  SoupState get initialState => InitialSoupState();

  @override
  Stream<SoupState> mapEventToState(
    SoupEvent event,
  ) async* {
    if (event is FetchSoupEvent) {
      Response response = await dio.request(event.url);
      print(response.data);
      var document = parse(response.data);

      var ele = document.getElementsByTagName("div")[0].attributes;
      print(document);
    }
  }
}
