import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/models/novel_text_response.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';

class NovelTextBloc extends Bloc<NovelTextEvent, NovelTextState> {
  ApiClient client;
  int id;

  NovelTextBloc(this.client, {@required this.id});

  @override
  NovelTextState get initialState => InitialNovelTextState();

  @override
  Stream<NovelTextState> mapEventToState(
    NovelTextEvent event,
  ) async* {
    if (event is FetchEvent) {
     try{
       var response = await client.getNovelText(id);
       NovelTextResponse novelTextResponse =
       NovelTextResponse.fromJson(response.data);
       yield DataNovelState(novelTextResponse);
     }catch(e){}
    }
  }
}
