import 'package:meta/meta.dart';

@immutable
abstract class HistoryPersistEvent {}
class FetchHistoryPersistEvent extends HistoryPersistEvent{}