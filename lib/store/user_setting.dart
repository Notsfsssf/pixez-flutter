import 'package:mobx/mobx.dart';
part 'user_setting.g.dart';

class UserSetting = _UserSettingBase with _$UserSetting;

abstract class _UserSettingBase with Store {
  @observable
  int zoomQuality = 0;
  @action
  void change(int value){
    zoomQuality = value;
  }
  
}