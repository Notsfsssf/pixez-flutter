import 'package:meta/meta.dart';
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/page/picture/bloc/bloc.dart';

@immutable
abstract class BookmarkDetailState {}
  
class InitialBookmarkDetailState extends BookmarkDetailState {}

class DataBookmarkDetailState extends BookmarkDetailState{
  final BookMarkDetailResponse bookMarkDetailResponse;

  DataBookmarkDetailState(this.bookMarkDetailResponse);
}