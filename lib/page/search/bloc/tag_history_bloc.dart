import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pixez/models/tags.dart';
import './bloc.dart';

class TagHistoryBloc extends Bloc<TagHistoryEvent, TagHistoryState> {
  @override
  TagHistoryState get initialState => InitialTagHistoryState();

  @override
  Stream<TagHistoryState> mapEventToState(
    TagHistoryEvent event,
  ) async* {
    if (event is FetchAllTagHistoryEvent) {
      TagsPersistProvider tagsPersistProvider = TagsPersistProvider();
      await tagsPersistProvider.open();
      final results = await tagsPersistProvider.getAllAccount();
      yield TagHistoryDataState(results);
    }
    if (event is DeleteAllTagHistoryEvent) {
      TagsPersistProvider tagsPersistProvider = TagsPersistProvider();
      await tagsPersistProvider.open();
      final result = await tagsPersistProvider.deleteAll();
      yield TagHistoryDataState([]);
    }
  }
}
