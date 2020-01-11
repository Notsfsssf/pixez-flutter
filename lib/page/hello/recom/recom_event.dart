import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class RecomEvent extends Equatable {
  const RecomEvent();
}
class FetchEvent extends RecomEvent{
  @override
  List<Object> get props => [];

}
class LoadMoreEvent extends RecomEvent{
  final String nextUrl;
  final List<Illusts> illusts;
  LoadMoreEvent(this.nextUrl,this.illusts);
  @override
  List<Object> get props => [illusts,nextUrl];
}