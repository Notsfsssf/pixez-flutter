import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/user_preview.dart';

abstract class NewPainterState extends Equatable {
  const NewPainterState();
}

class InitialNewPainterState extends NewPainterState {



  @override
  List<Object> get props => [];
}

class DataState extends NewPainterState {
  final List<UserPreviews> users;
  final String nextUrl;
  DataState(this.users, this.nextUrl);
  @override
  List<Object> get props => [users,nextUrl];
}
class FailState extends NewPainterState{
  @override
  // TODO: implement props
  List<Object> get props => [];
}
class LoadEndState extends NewPainterState{
  @override
  List<Object> get props => [];
}
