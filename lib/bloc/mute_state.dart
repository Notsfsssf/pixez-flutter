import 'package:meta/meta.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_user_id.dart';

@immutable
abstract class MuteState {}

class InitialMuteState extends MuteState {}

class DataMuteState extends MuteState {
  final List<BanIllustIdPersist> banIllustIds;
  final List<BanUserIdPersist> banUserIds;

  DataMuteState(this.banIllustIds, this.banUserIds);
}
