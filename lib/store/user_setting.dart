import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'user_setting.g.dart';

class UserSetting = _UserSettingBase with _$UserSetting;

abstract class _UserSettingBase with Store {
  SharedPreferences prefs;
  static const String ZOOM_QUALITY_KEY = "zoom_quality";
  static const String SAVE_FORMAT_KEY = "save_format";
  @observable
  int zoomQuality = 0;
  @observable
  int languageNum = 0;
  @observable
  String path = "";
  @observable
  String format = "";
  static const String intialFormat = "{illust_id}_p{part}";
  @action
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    zoomQuality = prefs.getInt(ZOOM_QUALITY_KEY) ?? 0;
    path = prefs.getString("store_path") ??
        (await getExternalStorageDirectory()).path + '/pxez';
    languageNum = prefs.getInt("language_num") ?? 0;
    format = prefs.getString(SAVE_FORMAT_KEY) ?? intialFormat;
    ApiClient.Accept_Language = languageList[languageNum];
    I18n.onLocaleChanged(I18n.delegate.supportedLocales[languageNum]);
  }

  @action
  Future<String> getPath() async {
    path = prefs.getString("store_path");
    return path;
  }

  @action
  setPath(result) {
    path = result;
  }

  final languageList = ['zh-CN', 'en-US'];
  @action
  setLanguageNum(int value) async {
    await prefs.setInt("language_num", value);
    languageNum = value;
    ApiClient.Accept_Language = languageList[languageNum];
    I18n.onLocaleChanged(I18n.delegate.supportedLocales[languageNum]);
  }

  @action
  setFormat(String format) async {
    await prefs.setString(SAVE_FORMAT_KEY, format.trim());
    this.format = format;
  }

  @action
  Future<void> change(int value) async {
    await prefs.setInt(ZOOM_QUALITY_KEY, value);
    zoomQuality = value;
  }
}
