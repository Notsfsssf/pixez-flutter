import 'package:pixez/models/key_value_pair.dart';

class KVer {
  KVProvider kvProvider = KVProvider();

  KVer() {
    kvProvider.open();
  }

  Future<void> setExp(String key, String value, int expireTime) async {
    await kvProvider.insert(KVPair(
        key: key,
        value: value,
        expireTime: expireTime,
        dateTime: DateTime.now().millisecondsSinceEpoch));
  }

  set(String key, String value) async {
    setExp(key, value, 0);
  }

  Future<String> get(String key) async {
    KVPair kvPair = await kvProvider.getAccount(key);
    if (kvPair == null) return null;
    bool expire = kvPair.expireTime == 0
        ? false
        : (DateTime.now().millisecondsSinceEpoch - kvPair.dateTime) >
            kvPair.expireTime;
    if (expire) {
      await kvProvider.delete(key);
      return null;
    } else
      return kvPair.value;
  }

  Future<void> remove(String key) async {
    try {
      await kvProvider.remove(key);
    } catch (e) {}
  }
}
