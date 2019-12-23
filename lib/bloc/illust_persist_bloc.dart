import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pixez/models/illust_persist.dart';
import './bloc.dart';

class IllustPersistBloc extends Bloc<IllustPersistEvent, IllustPersistState> {
  @override
  IllustPersistState get initialState => InitialIllustPersistState();

  @override
  Stream<IllustPersistState> mapEventToState(
    IllustPersistEvent event,
  ) async* {
       if (event is FetchIllustPersistEvent) {
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      final result = await illustPersistProvider.getAllAccount();
      yield DataIllustPersistState(result);
    }
    if (event is InsertIllustPersistEvent) {
      final illust = event.illusts;
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      await illustPersistProvider.insert(IllustPersist()
        ..time = DateTime.now().millisecondsSinceEpoch
        ..userId = illust.user.id
        ..pictureUrl = illust.imageUrls.squareMedium
        ..illustId = illust.id);
      yield InsertSuccessState();
    }
    if (event is DeleteIllustPersistEvent) {
      final id = event.id;
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      await illustPersistProvider.delete(id);
      yield DeleteSuccessState();
    }
    if (event is DeleteAllIllustPersistEvent) {
      IllustPersistProvider illustPersistProvider = IllustPersistProvider();
      await illustPersistProvider.open();
      illustPersistProvider.deleteAll();
      yield DeleteSuccessState();
    }
  }
}
