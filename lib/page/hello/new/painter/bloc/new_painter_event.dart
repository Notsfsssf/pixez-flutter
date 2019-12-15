import 'package:equatable/equatable.dart';
import 'package:pixez/models/user_preview.dart';

abstract class NewPainterEvent extends Equatable {
  const NewPainterEvent();
}

class  FetchPainterEvent extends NewPainterEvent {
  final int id;

 final String retrict;
  FetchPainterEvent(this.id, this.retrict);

  @override
  List<Object> get props => [id,retrict];
  
}
class LoadMoreEvent extends NewPainterEvent {
  final String nextUrl;
  final List<UserPreviews> users;

  LoadMoreEvent(this.nextUrl, this.users);

  @override
  List<Object> get props => [users, nextUrl];
}