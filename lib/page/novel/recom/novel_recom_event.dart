import 'package:meta/meta.dart';
import 'package:pixez/models/novel_recom_response.dart';

@immutable
abstract class NovelRecomEvent {}
class FetchNovelRecomEvent extends NovelRecomEvent{}
class LoadMoreNovelRecomEvent extends NovelRecomEvent{
 final String nextUrl;
 final List<Novel> novels;
  LoadMoreNovelRecomEvent( this.novels,this.nextUrl,);
}