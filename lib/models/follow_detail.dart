import 'package:json_annotation/json_annotation.dart';

part 'follow_detail.g.dart';

@JsonSerializable()
class FollowDetail {
  @JsonKey(name: 'is_followed')
  final bool isFollowed;
  @JsonKey(name: 'restrict')
  final String restrict;

  FollowDetail({required this.isFollowed, required this.restrict});

  factory FollowDetail.fromJson(Map<String, dynamic> json) =>
      _$FollowDetailFromJson(json);

  Map<String, dynamic> toJson() => _$FollowDetailToJson(this);
}
