import 'package:json_annotation/json_annotation.dart';
import 'package:pixez/models/tags.dart';

part 'export_tag_history_data.g.dart';

@JsonSerializable()
class ExportData {
  List<TagsPersist>? tagHisotry;
  List<String>? bookTags;

  ExportData({this.tagHisotry, this.bookTags});

  factory ExportData.fromJson(Map<String, dynamic> json) =>
      _$ExportDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExportDataToJson(this);
}
