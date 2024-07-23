import 'package:json_annotation/json_annotation.dart';
part 'app_info.g.dart';

@JsonSerializable()
class AppInfos {
  AppInfos({required this.infos});

  @JsonKey(name: 'datas')
  List<AppInfo> infos;

  factory AppInfos.fromJson(Map<String, dynamic> json) => _$AppInfosFromJson(json);
  Map<String, dynamic> toJson() => _$AppInfosToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class AppInfo {
  AppInfo({
    required this.package,
    required this.label,
    required this.minSdk,
    required this.targetSdk,
    required this.versionName,
    required this.versionCode,
    required this.enabled,
    required this.hide,
    required this.uid,
    required this.sourceDir,
  });
  String package;
  String label;
  int minSdk;
  int targetSdk;
  String versionName;
  int versionCode;
  bool enabled;
  bool hide;
  int uid;
  String sourceDir;

  factory AppInfo.fromJson(Map<String, dynamic> json) => _$AppInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AppInfoToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }
}
