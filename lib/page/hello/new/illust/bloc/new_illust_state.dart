import 'package:pixez/models/illust.dart';

abstract class NewIllustState {
  const NewIllustState();
}

class InitialNewIllustState extends NewIllustState {}

class FailIllustState extends NewIllustState {}

class RefreshFailIllustState extends NewIllustState {}

class DataNewIllustState extends NewIllustState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataNewIllustState(this.illusts, this.nextUrl);
}

class LoadMoreSuccessState extends NewIllustState {
}
