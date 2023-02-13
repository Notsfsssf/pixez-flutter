import 'package:json_annotation/json_annotation.dart';

part 'show_ai_response.g.dart';

@JsonSerializable()
class ShowAIResponse {
  @JsonKey(name: 'show_ai')
  bool showAI;

  ShowAIResponse({
    required this.showAI,
  });

  factory ShowAIResponse.fromJson(Map<String, dynamic> json) =>
      _$ShowAIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ShowAIResponseToJson(this);
}
