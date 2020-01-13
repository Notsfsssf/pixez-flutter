import 'package:meta/meta.dart';

@immutable
abstract class LoginEvent {}

class ClickToAuth extends LoginEvent {
  final String username;
  final String password;
  String deviceToken = "pixiv";

  ClickToAuth({
    this.deviceToken,
    @required this.username,
    @required this.password,
  });
}
