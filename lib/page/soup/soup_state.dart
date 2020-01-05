import 'package:meta/meta.dart';

@immutable
abstract class SoupState {}

class InitialSoupState extends SoupState {}

class DataSoupState extends SoupState {}
