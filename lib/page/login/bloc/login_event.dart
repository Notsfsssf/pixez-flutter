import 'package:meta/meta.dart';

@immutable
abstract class LoginEvent {
  
}
class ClickToAuth extends LoginEvent{
  final String username;
  final String password;

  ClickToAuth({
    @required this.username,
    @required this.password,
  });
  @override
  List<Object> get props => [username, password];
  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}