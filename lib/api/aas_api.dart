// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:android_api_server/model/model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' hide Headers;
part 'aas_api.g.dart';

String deserializedynamic(dynamic data) {
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  return encoder.convert(data);
}

@RestApi(baseUrl: "", parser: Parser.JsonSerializable)
abstract class Api {
  factory Api(Dio dio, {String baseUrl}) = _Api;

  /// 获取应用列表
  /// get all app info
  @GET('/all_app_info')
  Future<AppInfos> getAllAppInfo({
    @DioOptions() RequestOptions? options,
    @Query("is_system_app") bool? isSystemApp,
  });

  /// 获取应用详情
  /// get app detail
  @GET('/app_details')
  Future<AppDetail> getAppDetail({
    @DioOptions() RequestOptions? options,
    @Query("package") String? package,
  });

  /// 通过包名获取 MainActivity
  /// get main activity by package
  @GET('/app_main_activity')
  Future<AppMainActivity> getAppMainActivity({
    @DioOptions() RequestOptions? options,
    @Query("package") String? package,
  });

  /// 通过包名获取 所有的 Activitys
  /// get all activitys by package
  @GET('/app_activitys')
  Future<AppActivitys> getAppActivity({
    @DioOptions() RequestOptions? options,
    @Query("package") String? package,
  });

  /// 通过包名获取所有的 Permission
  /// get all permissions by package
  @GET('/app_permission')
  Future<AppPermissions> getAppPermissions({
    @DioOptions() RequestOptions? options,
    @Query("package") String? package,
  });

  /// 启动App
  /// open app by package
  @GET('/openapp')
  Future<String> openAppByPackage({
    @DioOptions() RequestOptions? options,
    @Query("package") String? package,
    @Query("activity") String? activity,
    @Query("displayId") String? displayId,
  });

  /// 启动App
  /// open app by package
  @GET('/start_activity')
  Future<DefaultMap> startActivity({
    @DioOptions() RequestOptions? options,
    @Query("package") String? package,
    @Query("activity") String? activity,
    @Query("displayId") String? displayId,
  });

  /// 停止App
  /// stop app by package
  @GET('/stop_activity')
  Future<String> stopActivity({
    @DioOptions() RequestOptions? options,
    @Query("package") String? package,
  });

  /// 启动App
  /// open app by package
  @GET('/appinfos')
  Future<String> getAppInfos({
    @DioOptions() RequestOptions? options,
    @Query("apps") required List<String> apps,
  });

  /// 启动App
  /// open app by package
  @POST('/cmd')
  Future<CmdResult> execCMD({
    @DioOptions() RequestOptions? options,
    @Body() required String cmd,
  });

  @GET('/display')
  Future<Displays> display({
    @DioOptions() RequestOptions? options,
    @Query("action") required String action,
  });

  /// 获得显示器列表
  /// get displays
  @GET('/tasks')
  Future<Tasks> getTasks({
    @DioOptions() RequestOptions? options,
  });

  @POST('/display?action=createVirtualDisplay')
  Future<Display> createVirtualDisplay({
    @DioOptions() RequestOptions? options,
    @Query("width") required String width,
    @Query("height") required String height,
    @Query("density") required String density,
    @Query("useDeviceConfig") bool? useDeviceConfig,
  });
}
