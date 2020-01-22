import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_user_id.dart';

import './bloc.dart';

class MuteBloc extends Bloc<MuteEvent, MuteState> {
  BanIllustIdProvider banIllustIdProvider = BanIllustIdProvider();
  var banUserIdProvider = BanUserIdProvider();

  @override
  MuteState get initialState => InitialMuteState();

  @override
  Stream<MuteState> mapEventToState(
    MuteEvent event,
  ) async* {
    if (event is FetchMuteEvent) {
      await banIllustIdProvider.open();
      await banUserIdProvider.open();
      var illustids = await banIllustIdProvider.getAllAccount();
      var userids = await banUserIdProvider.getAllAccount();
      yield DataMuteState(illustids, userids);
    }
    if (event is InsertBanIllustEvent) {
      await banIllustIdProvider.open();
      banIllustIdProvider.insert(BanIllustIdPersist()
        ..illustId = event.id
        ..name = event.name);
      add(FetchMuteEvent());
    }
    if (event is InsertBanUserEvent) {
      await banUserIdProvider.open();
      await banUserIdProvider.insert(BanUserIdPersist()
        ..userId = event.id
        ..name = event.name);
      add(FetchMuteEvent());
    }
    if (event is DeleteUserEvent) {
      await banUserIdProvider.open();
      await banUserIdProvider.delete(event.id);
      add(FetchMuteEvent());
    }
    if (event is DeleteIllustEvent) {
      await banIllustIdProvider.open();
      await banIllustIdProvider.delete(event.id);
      add(FetchMuteEvent());
    }
  }
}
