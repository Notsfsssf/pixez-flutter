import 'package:meta/meta.dart';

@immutable
abstract class IapState {}

class InitialIapState extends IapState {}

class DataIapState extends IapState {
}

class ThanksState extends IapState {}
