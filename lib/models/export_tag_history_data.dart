import 'package:json_annotation/json_annotation.dart';
import 'package:pixez/models/tags.dart';

part 'export_tag_history_data.g.dart';

@JsonSerializable()
class ExportTagHistoryData {
  List<TagsPersist> data = [];
  String type = "tag_history";

  ExportTagHistoryData({required this.data, required this.type});

  factory ExportTagHistoryData.fromJson(Map<String, dynamic> json) =>
      _$ExportTagHistoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExportTagHistoryDataToJson(this);
}
