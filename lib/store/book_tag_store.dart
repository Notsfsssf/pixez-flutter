import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'book_tag_store.g.dart';

class BookTagStore = _BookTagStoreBase with _$BookTagStore;

abstract class _BookTagStoreBase with Store {
  static const BOOK_TAG_LIST = 'book_tag_list';
  @observable
  ObservableList<String> bookTagList = ObservableList();
  SharedPreferences? pre;

  @action
  init() async {
    try {
      pre = await SharedPreferences.getInstance();
      final bookList = pre!.getStringList(BOOK_TAG_LIST) ?? [];
      bookTagList.clear();
      bookTagList.addAll(bookList);
    } catch (e) {}
  }

  @action
  Future<void> bookTag(String tag) async {
    if (bookTagList.contains(tag)) return;
    await pre!.setStringList(BOOK_TAG_LIST, bookTagList..add(tag));
  }

  @action
  Future<void> unBookTag(String tag) async {
    await pre!.setStringList(BOOK_TAG_LIST, bookTagList..remove(tag));
  }

  @action
  reset() async {
    await pre!.remove(BOOK_TAG_LIST);
    bookTagList.clear();
  }
}
