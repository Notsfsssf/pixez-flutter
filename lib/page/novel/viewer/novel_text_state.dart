import 'package:meta/meta.dart';
import 'package:pixez/models/novel_text_response.dart';

@immutable
abstract class NovelTextState {}

class InitialNovelTextState extends NovelTextState {}
class DataNovelState extends NovelTextState{
  final NovelTextResponse novelTextResponse;
  DataNovelState(this.novelTextResponse);

}
