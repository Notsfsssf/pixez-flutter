import 'package:meta/meta.dart';

@immutable
abstract class ControllerState {}

class InitialControllerState extends ControllerState {}
class ScrollToTopState extends ControllerState{
final String name;

  ScrollToTopState(this.name);
}