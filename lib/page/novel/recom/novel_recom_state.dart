import 'package:meta/meta.dart';
import 'package:pixez/models/novel_recom_response.dart';

@immutable
abstract class NovelRecomState {}

class InitialNovelRecomState extends NovelRecomState {}

class DataNovelRecomState extends NovelRecomState {
  final List<Novel> novels;
  final String nextUrl;

  DataNovelRecomState(this.novels, this.nextUrl);
}
