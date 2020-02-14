import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';

class NovelRecomBloc extends Bloc<NovelRecomEvent, NovelRecomState> {
  final ApiClient client;

  NovelRecomBloc(this.client);

  @override
  NovelRecomState get initialState => InitialNovelRecomState();

  String getPrettyJSONString(jsonObject) {
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }

  @override
  Stream<NovelRecomState> mapEventToState(
    NovelRecomEvent event,
  ) async* {
    if (event is LoadMoreNovelRecomEvent) {
if(event.nextUrl!=null&&event.nextUrl.isNotEmpty) {
  try {
    var response = await client.getNext(event.nextUrl);
    NovelRecomResponse novelRecomResponse =
    NovelRecomResponse.fromJson(response.data);
    yield DataNovelRecomState(
        event.novels..addAll(novelRecomResponse.novels),
        novelRecomResponse.nextUrl);
  } catch (e) {}
}
    }
    if (event is NovelRecomEvent) {
     try{
       var response = await client.getNovelRecommended();
       NovelRecomResponse novelRecomResponse =
       NovelRecomResponse.fromJson(response.data);
       yield DataNovelRecomState(
           novelRecomResponse.novels, novelRecomResponse.nextUrl);
     }catch(e){

     }
    }
  }
}
