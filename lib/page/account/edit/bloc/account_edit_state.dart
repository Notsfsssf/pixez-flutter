import 'package:meta/meta.dart';

@immutable
abstract class AccountEditState {}
  
class InitialAccountEditState extends AccountEditState {}
class SuccessAccountEditState extends AccountEditState{}
class FailAccountEditState extends AccountEditState{
  FailAccountEditState(e);
}