import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/illust_persist.dart';

import './bloc.dart';

class HistoryPersistBloc
    extends Bloc<HistoryPersistEvent, HistoryPersistState> {
  @override
  HistoryPersistState get initialState => InitialHistoryPersistState();

  @override
  Stream<HistoryPersistState> mapEventToState(
    HistoryPersistEvent event,
  ) async* {
    if (event is FetchHistoryPersistEvent) {
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      final result = await illustPersistProvider.getAllAccount();
      yield DataHistoryPersistState(result);
    }
    if (event is InsertHistoryPersistEvent) {
      final illust = event.illusts;
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      illustPersistProvider.insert(IllustPersist()
        ..time = DateTime.now().millisecondsSinceEpoch
        ..userId = illust.user.id
        ..pictureUrl = illust.imageUrls.squareMedium
        ..illustId = illust.id);
      yield InsertSuccessState();
    }
    if (event is DeleteHistoryPersistEvent) {
      final id = event.id;
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      await illustPersistProvider.delete(id);
      yield DeleteSuccessState();
    }
    if (event is DeleteAllHistoryPersistEvent) {
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      illustPersistProvider.deleteAll();
      yield DeleteSuccessState();
    }
  }
}
