import 'package:meta/meta.dart';

@immutable
abstract class AccountEvent {}

class FetchDataBaseEvent extends AccountEvent {
  @override
  List<Object> get props => [];
}
