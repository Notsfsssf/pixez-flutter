import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class NewIllustEvent extends Equatable {
  const NewIllustEvent();
}
class FetchEvent extends NewIllustEvent{
  final String restrict;

  FetchEvent(this.restrict);

  @override
  List<Object> get props => [restrict];

}
class LoadMoreEvent extends NewIllustEvent{
  final String nextUrl;
  final List<Illusts> illusts;
  LoadMoreEvent(this.nextUrl,this.illusts);
  @override
  List<Object> get props => [illusts,nextUrl];

}