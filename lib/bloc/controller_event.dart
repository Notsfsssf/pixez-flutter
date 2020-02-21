import 'package:meta/meta.dart';

@immutable
abstract class ControllerEvent {}
class ScrollToTopEvent extends ControllerEvent{
  final String name;

  ScrollToTopEvent(this.name);
}