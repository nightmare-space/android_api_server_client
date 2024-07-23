// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppInfos _$AppInfosFromJson(Map<String, dynamic> json) => AppInfos(
      infos: (json['datas'] as List<dynamic>)
          .map((e) => AppInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AppInfosToJson(AppInfos instance) => <String, dynamic>{
      'datas': instance.infos,
    };

AppInfo _$AppInfoFromJson(Map<String, dynamic> json) => AppInfo(
      package: json['package'] as String,
      label: json['label'] as String,
      minSdk: (json['minSdk'] as num).toInt(),
      targetSdk: (json['targetSdk'] as num).toInt(),
      versionName: json['versionName'] as String,
      versionCode: (json['versionCode'] as num).toInt(),
      enabled: json['enabled'] as bool,
      hide: json['hide'] as bool,
      uid: (json['uid'] as num).toInt(),
      sourceDir: json['sourceDir'] as String,
    );

Map<String, dynamic> _$AppInfoToJson(AppInfo instance) => <String, dynamic>{
      'package': instance.package,
      'label': instance.label,
      'minSdk': instance.minSdk,
      'targetSdk': instance.targetSdk,
      'versionName': instance.versionName,
      'versionCode': instance.versionCode,
      'enabled': instance.enabled,
      'hide': instance.hide,
      'uid': instance.uid,
      'sourceDir': instance.sourceDir,
    };
