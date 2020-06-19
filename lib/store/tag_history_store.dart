import 'package:mobx/mobx.dart';
import 'package:pixez/models/tags.dart';
part 'tag_history_store.g.dart';

class TagHistoryStore = _TagHistoryStoreBase with _$TagHistoryStore;

abstract class _TagHistoryStoreBase with Store {
  TagsPersistProvider tagsPersistProvider = TagsPersistProvider();
  ObservableList<TagsPersist> tags = ObservableList();
  @action
  fetch() async {
    await tagsPersistProvider.open();
    var result = await tagsPersistProvider.getAllAccount();
    tags.clear();
    tags.addAll(result);
  }
 @action
  insert(TagsPersist tagsPersist) async {
    await tagsPersistProvider.open();
    await tagsPersistProvider.insert(tagsPersist);
    await fetch();
  }
 @action
  deleteAll() async {
    await tagsPersistProvider.open();
    await tagsPersistProvider.deleteAll();
    await fetch();
  }
}
