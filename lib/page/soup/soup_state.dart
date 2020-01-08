import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:pixez/page/soup/bloc.dart';

@immutable
abstract class SoupState {}

class InitialSoupState extends SoupState {}

class DataSoupState extends SoupState {
 final List<AmWork> amWorks;

final String description;
  DataSoupState(this.amWorks, this.description);
}
