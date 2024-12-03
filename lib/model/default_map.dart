import 'package:json_annotation/json_annotation.dart';
part 'default_map.g.dart';
// {
//     "result": "success"
// }
@JsonSerializable()
class DefaultMap {
  DefaultMap({
    required this.result,
  });

  String result;

  factory DefaultMap.fromJson(Map<String, dynamic> json) => _$DefaultMapFromJson(json);
  Map<String, dynamic> toJson() => _$DefaultMapToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }
}