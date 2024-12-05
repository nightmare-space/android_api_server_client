// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppDetail _$AppDetailFromJson(Map<String, dynamic> json) => AppDetail(
      firstInstallTime: (json['firstInstallTime'] as num).toInt(),
      lastUpdateTime: (json['lastUpdateTime'] as num).toInt(),
      dataDir: json['dataDir'] as String,
      nativeLibraryDir: json['nativeLibraryDir'] as String,
    );

Map<String, dynamic> _$AppDetailToJson(AppDetail instance) => <String, dynamic>{
      'firstInstallTime': instance.firstInstallTime,
      'lastUpdateTime': instance.lastUpdateTime,
      'dataDir': instance.dataDir,
      'nativeLibraryDir': instance.nativeLibraryDir,
    };
