import 'package:meta/meta.dart';

@immutable
abstract class LoginState {}
  
class InitialLoginState extends LoginState {
  
}
class SuccessState extends LoginState{

}
class FailState extends LoginState{
final String failMessage;
 FailState(this.failMessage);
@override
List<Object> get props => [failMessage];

}
