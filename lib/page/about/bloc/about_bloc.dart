import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:package_info/package_info.dart';
import './bloc.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {
  @override
  AboutState get initialState => InitialAboutState();

  @override
  Stream<AboutState> mapEventToState(
    AboutEvent event,
  ) async* {
    if (event is FetchAboutEvent) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      yield DataAbouState(packageInfo);
    }
  }
}
