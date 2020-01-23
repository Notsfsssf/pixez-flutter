import 'package:meta/meta.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/ban_user_id.dart';

@immutable
abstract class MuteState {}

class InitialMuteState extends MuteState {}

class DataMuteState extends MuteState {
  final List<BanIllustIdPersist> banIllustIds;
  final List<BanUserIdPersist> banUserIds;
  final List<BanTagPersist> banTags;

  DataMuteState(this.banIllustIds, this.banUserIds, this.banTags);
}
