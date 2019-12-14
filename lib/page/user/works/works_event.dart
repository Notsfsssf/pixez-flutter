import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class WorksEvent extends Equatable {
  const WorksEvent();
}

class FetchWorksEvent extends WorksEvent {
  final int user_id;
  final String type;

  FetchWorksEvent(this.user_id, this.type);

  @override
  List<Object> get props => [user_id, type];
}

class LoadMoreEvent extends WorksEvent {
  final String nextUrl;
  final List<Illusts> illusts;

  LoadMoreEvent(this.nextUrl, this.illusts);

  @override
  List<Object> get props => [illusts, nextUrl];
}
